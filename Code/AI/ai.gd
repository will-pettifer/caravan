@abstract
class_name AI 


var game_manager: GameManager
var player: int


@abstract func move_search()


func _init(game_manager, player) -> void:
	self.game_manager = game_manager
	self.player = player


func random():
	var moves = generate_moves()
	var rand = randi() % moves.size()
	
	return moves[rand]


func generate_moves(player = self.player):
	var moves: Array[Move]
	
	match player:
		1: player = 0
		-1: player = 4
	
	for i in range(player * 10, 40 + player * 10):
		if game_manager.position[i] == "0": continue
		for j in range(player, 3 + player):
			if i / 10 != j:
				moves.append(Move.new(i, j * 10 + (i % 10)))
	
	return moves

func evaluate_position():
	var score = game_manager.win_check()
	
	if score == 0.1: return 0
	
	score *= 100
	
	var p0 = 0
	var p1 = 0
	for i in range(0, 3):
		p0 += 30 - abs(30 - game_manager.values[i])
	for i in range(4, 7):
		p1 += 30 - abs(30 - game_manager.values[i])
	
	score += p0 + p1 * -1
	
	return score
