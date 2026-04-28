class_name Willow
extends AI


func move_search(player = self.player):
	var moves = generate_moves()
	var best_move
	var best_score = -INF
	
	for move in moves:
		game_manager.move(move)
		var eval = evaluate_position() * player
		
		if eval >= best_score:
			best_score = eval
			best_move = move
		
		game_manager.unmove(move)
	
	return best_move
