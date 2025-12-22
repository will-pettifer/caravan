class_name Card

extends Control


var state: State = State.HAND
var state_buffer: State
var value: int
var time: float

enum State {HAND, FOCUSED, FLOATING, ZONE}



func _ready() -> void:
	pass


func _process(delta: float) -> void:
	match state:
		State.HAND:
			pass
		State.FLOATING:
			position = get_viewport().get_mouse_position()
		State.ZONE:
			pass


func _input(event: InputEvent) -> void:
	if state == State.HAND || State.ZONE:
		if event.is_action_pressed("select"):
			
			state_buffer = state
			state = State.FLOATING
	if state == State.FLOATING:
		if event.is_action_pressed("select"):
			state = state_buffer


func focus_enter():
	state_buffer = state
	state = State.FOCUSED

func focus_exit():
	state = state_buffer

func _on_mouse_entered() -> void:
	focus_enter()
	print("in")

func _on_mouse_exited() -> void:
	focus_exit()
	print("out")

func _on_focus_entered() -> void:
	focus_enter()

func _on_focus_exited() -> void:
	focus_exit()
