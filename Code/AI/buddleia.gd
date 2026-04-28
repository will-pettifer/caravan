class_name Buddleia
extends AI


func move_search(player = self.player):
	var moves = generate_moves()
	
	return moves[randi_range(0, moves.size() - 1)]
