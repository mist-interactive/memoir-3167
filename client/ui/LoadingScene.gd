extends Node2D
class_name Loader
var tasks: Array[Task]
@export var progressBar: ProgressBar

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

func run() -> void:
	var total_weight: float = 0.0
	var completed_weight: float = 0.0
	progressBar.value = 0
	for task in tasks:
		total_weight += task.weight

	while !tasks.is_empty():
		var task: Task = tasks.pop_front()
		await task.execute.call()
		completed_weight += task.weight
		print("Completed task: ", task.name)
		progressBar.value = (completed_weight / total_weight) * 100

func _ready() -> void:
	stage("test1", func(): await get_tree().create_timer(1).timeout)\
	.stage("test2", func(): await get_tree().create_timer(1).timeout)\
	.stage("test3", func(): await get_tree().create_timer(1).timeout)\
	.stage("test4", func(): await get_tree().create_timer(1).timeout)\
	.stage("test5", func(): await get_tree().create_timer(1).timeout)\
	.run()

func _process(delta: float) -> void:
	pass
