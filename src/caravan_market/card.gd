extends Area2D
class_name Card


@export var offset: Vector2 = Vector2(0, 0)

var game_manager
var state: State
var value: int = 1
var parent_zone: Zone
var is_focused: bool
var timer: float = 0

enum State {
	ZONE,			# In the zone
	SELECTED,		# Cursor hovering over
	FLOATING		# Held by the cursor
}


func _ready() -> void:
	game_manager = get_parent().get_parent()
	
	$AnimatedSprite2D.animation = "default"
	$AnimatedSprite2D.frame = value - 1


func _process(delta: float) -> void:
	timer += delta
	match state:
		State.FLOATING:
			#position = get_viewport().get_mouse_position() - offset
			rotation = sin(timer * 3) / 2
			$AnimatedSprite2D.frame = value + 9
		State.ZONE:
			rotation = 0
			$AnimatedSprite2D.frame = value - 1


func focus_enter():
	is_focused = true
	game_manager.overlapping_objects.append(self)

func focus_exit():
	is_focused = false
	game_manager.overlapping_objects.erase(self)

func _on_mouse_entered() -> void:
	focus_enter()

func _on_mouse_exited() -> void:
	focus_exit()
