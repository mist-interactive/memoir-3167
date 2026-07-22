extends Node2D
class_name Loader
var tasks: Array[Task]
@export var progressBar: ProgressBar
@onready var taskLabel = $CanvasLayer/Label
@onready var background = $WinterOfWonder

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
	self.hide_loader()
	
func run() -> void:
	var total_weight: float = 0.0
	var completed_weight: float = 0.0
	progressBar.value = 0
	self.show_loader()
	for task in tasks:
		total_weight += task.weight

	for task: Task in tasks:
		taskLabel.text = task.name
		await task.execute.call()
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

func wait_untill(cond: Callable) -> void:
	while !cond.call():
		await get_tree().process_frame
