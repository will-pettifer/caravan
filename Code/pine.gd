class_name Pine
extends AI


func move_search(player = self.player):
	var moves = generate_moves(player)
	var best_move
	var best_score = -INF
	var depth = 3
	
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
