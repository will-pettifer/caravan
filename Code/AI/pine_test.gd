class_name PineTest
extends AI


func move_search(player = self.player):
	var moves = generate_moves(player)
	var best_move
	var best_score = -INF
	var depth = 2
	
	for move in moves:
		game_manager.move(move)
		
		var eval = -recursive_search(-player, depth - 1)
		
		if eval >= best_score:
			best_score = eval
			best_move = move
		
		game_manager.unmove(move)
	
	return best_move


func recursive_search(player, depth):
	var win_check = game_manager.win_check()
	if win_check == INF or win_check == -INF:
		return win_check * player
	
	if depth <= 0: return evaluate_position() * player
	
	var moves = generate_moves(player)
	var best_score = -INF
	
	for move in moves:
		game_manager.move(move)
		var eval
		
		eval = -recursive_search(-player, depth - 1)
		
		if eval > best_score: best_score = eval
		
		game_manager.unmove(move)
	
	return best_score
