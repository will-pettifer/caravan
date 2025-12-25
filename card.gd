class_name Card

extends Area2D


@export var offset: Vector2 = Vector2(0, 0)

var state: State
var value: int = 1
var parent_zone: Zone

enum State {
	ZONE,			# In the zone
	FOCUSED,		# Cursor hovering over
	FLOATING		# Held by the cursor
}


func _ready() -> void:
	$AnimatedSprite2D.animation = "default"
	$AnimatedSprite2D.frame = value - 1


func _process(delta: float) -> void:
	match state:
		State.FLOATING:
			position = get_viewport().get_mouse_position() - offset
		State.ZONE:
			pass


func _input(event: InputEvent) -> void:
	if state != State.FOCUSED: return
	if event.is_action_pressed("select"):
		GameManager.pickup(self, parent_zone)
	elif event.is_action_pressed("cancel"):
		GameManager.cancel()


func focus_enter():
	if state == State.FLOATING: return
	state = State.FOCUSED

func focus_exit():
	if state == State.FLOATING: return
	state = State.ZONE

func _on_mouse_entered() -> void:
	focus_enter()

func _on_mouse_exited() -> void:
	focus_exit()
