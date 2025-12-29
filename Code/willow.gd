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
		if eval > best_score:
			best_score = eval
			best_move = move
		game_manager.unmove(move)
	
	return best_move


func generate_moves():
	var player = self.player
	var moves: Array[Move]
	player *= 4
	
	for i in range(player, player + 4):
		for j in game_manager.zones[i].size():
			for k in range(player, player + 3):
				if k == i: continue
				moves.append(Move.new(Vector2(i, j), k))
	
	return moves


func evaluate_position():
	var player = self.player
	var score = game_manager.win_check() * 100
	
	var p0 = 0
	var p1 = 0
	for i in range(0, 3):
		p0 += 30 - abs(30 - game_manager.values[i])
	for i in range(4, 7):
		p1 += 30 - abs(30 - game_manager.values[i])
	
	score += p0 + p1 * -1
	
	return score
