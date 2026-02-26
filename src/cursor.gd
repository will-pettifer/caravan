extends Node2D


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		position.y = event.position.y
		position.x = clamp(event.position.x, 0, 540)
