class_name Willow
extends AI


func move_search():
	var player = self.player
	var moves = generate_moves()
	var best_move
	var best_score = -INF
	
	match player:
		0:
			player = 1
		1:
			player = -1
	
	for move in moves:
		game_manager.move(move)
		var eval = evaluate_position() * player
		
		if eval >= best_score:
			best_score = eval
			best_move = move
		
		game_manager.unmove(move)
	
	return best_move


func evaluate_position():
	var player = self.player
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
