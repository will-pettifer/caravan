class_name Main
extends Node2D


var game_manager: GameManager

const GAME_MANAGER := preload("res://Code/game_manager.tscn")


func _ready() -> void:
	game_manager = get_node("GameManager")


func restart():
	game_manager.queue_free()
	
	game_manager = GAME_MANAGER.instantiate() as GameManager
	add_child(game_manager)
