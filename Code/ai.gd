@abstract
class_name AI 


var game_manager: GameManager
var player: int


func _init(game_manager, player) -> void:
	self.game_manager = game_manager
	self.player = player

@abstract func random()

@abstract func move_search()

@abstract func generate_moves()

@abstract func evaluate_position()
