extends Node3D


func _input(event: InputEvent) -> void:
	$SubViewport.push_input(event)
