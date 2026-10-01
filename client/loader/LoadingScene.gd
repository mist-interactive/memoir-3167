extends Node2D
class_name Loader
var tasks: Array[Task]
@export var progressBar: ProgressBar
@export var taskLabel: Label
@export var background: TextureRect

class Task:
	var weight: float
	var name: String
	var execute: Callable
	func _init( name: String, job: Callable, weight: float = 1.0) -> void:
		self.name = name
		self.execute = job
		self.weight = weight

func stage(name: String, job: Callable, weight: float = 1.0) -> Loader:
	tasks.append(Task.new(name, job, weight))
	return self
	
func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()
	hide_loader()

func _on_viewport_size_changed() -> void:
	background.position = Vector2.ZERO
	background.size = get_viewport_rect().size
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	
func run() -> void:
	var total_weight: float = 0.0
	var completed_weight: float = 0.0
	progressBar.value = 0
	self.show_loader()
	for task in tasks:
		total_weight += task.weight

	for task: Task in tasks:
		taskLabel.text = task.name
		var res: taskResult = await task.execute.call()
		if !res.done:
			taskLabel.text = res.err_msg
			return
		completed_weight += task.weight
		var target = completed_weight / total_weight * 100
		var tween = create_tween()
		tween.tween_property(progressBar, "value", target, 0.25)
		await tween.finished

	tasks.clear()
	self.hide_loader()

func show_loader() -> void:
	background.show()
	taskLabel.show()
	progressBar.show()
	
func hide_loader() -> void:
	background.hide()
	taskLabel.hide()
	progressBar.hide()

func wait_untill(cond: Callable, timeout: float = 5.0) -> bool:
	var elapsed: float = 0.0

	while not cond.call():
		if timeout > 0.0 && elapsed >= timeout:
			return false
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	
	return true
