class_name Main
extends Node3D


var game_manager: CaravanMarket

const GAME_MANAGER := preload("res://src/CaravanMarket/caravan_market.tscn")


func _ready() -> void:
	if OS.has_feature("release"):
		DisplayServer.window_set_size(Vector2i(1600, 900))
		DisplayServer.window_set_position(
			DisplayServer.screen_get_position() + 
			DisplayServer.screen_get_size() / 2 - 
			DisplayServer.window_get_size() / 2
		)


func restart():
	game_manager.queue_free()
	
	game_manager = GAME_MANAGER.instantiate() as CaravanMarket
	add_child(game_manager)
