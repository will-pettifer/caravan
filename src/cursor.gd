extends Node2D


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		position.y = clamp(event.position.y, 5, 535)
		position.x = clamp(event.position.x, 5, 535)
