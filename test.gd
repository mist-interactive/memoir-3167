extends Node2D

var server: Server

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	server = Server.new(778)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	server.acceptNewClients()
