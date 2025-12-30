extends Control


var game_manager: GameManager


func _ready() -> void:
	game_manager = get_parent()
	
	visible = true
	$Main.visible = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		esc()


func esc():
	if !game_manager.is_paused:
		game_manager.is_paused = true
		$Main.visible = true
		$Rules.visible = false
		$EndMessage.visible = false
	else:
		game_manager.is_paused = false
		$Main.visible = false
		$Rules.visible = false
		$EndMessage.visible = false


func end(p0_win: bool):
	game_manager.is_paused = true
	$EndMessage.visible = true
	
	if p0_win:
		$EndMessage/Label.text = "You win!"
	else:
		$EndMessage/Label.text = "You lose!"
	
	await get_tree().create_timer(3).timeout
	
	$EndMessage.visible = false
	game_manager.is_paused = false


func _on_start_game_pressed() -> void:
	game_manager.start_game()
	
	$Main/VBoxContainer/StartGame.text = "Reset Game"
	$Main.visible = false


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			game_manager.p1 = Willow.new(game_manager, 1)


func _on_player_starts_toggled(toggled_on: bool) -> void:
	game_manager.is_player_start = toggled_on


func _on_tutorial_pressed() -> void:
	$Main.visible = false
	$Rules.visible = true


func _on_back_pressed() -> void:
	$Rules.visible = false
	$Main.visible = true


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_menu_pressed() -> void:
	esc()
