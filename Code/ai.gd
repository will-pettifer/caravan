@abstract
class_name AI 


var game_manager: GameManager
var player: int


@abstract func move_search()

@abstract func evaluate_position()


func _init(game_manager, player) -> void:
	self.game_manager = game_manager
	self.player = player


func random():
	var moves = generate_moves()
	var rand = randi() % moves.size()
	
	return moves[rand]


func generate_moves():
	var player = self.player
	var moves: Array[Move]
	player *= 4
	
	for i in range(player * 10, 40 + player * 10):
		if game_manager.position[i] == "0": continue
		for j in range(player, 3 + player):
			if i / 10 != j:
				moves.append(Move.new(i, j * 10 + (i % 10)))
	
	return moves
