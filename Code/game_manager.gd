extends Node


var held_card: Card
var cooldown: float
var timer: float = 0
var main
var zones: Array
var zone_nodes: Array
var values: Array[int]

const COOLDOWN: float = 0.01


func _ready() -> void:
	main = get_tree().current_scene
	
	values.resize(8)
	zones.resize(8)
	for i in zones.size():
		zones[i] = []
	
	for i in 10:
		zones[3].append(i + 1)
		zones[7].append(i + 1)
	
	zone_nodes.resize(8)
	for i in 8:
		var mod
		match i:
			0, 1, 2:
				mod = "P" + str(i)
			3:
				mod = "P3Hand"
			4, 5, 6:
				mod = "E" + str(i)
			7:
				mod = "E7Hand"
		
		var node_path = "Zone" + mod
		zone_nodes[i] = main.get_node(node_path)


func _process(delta: float) -> void:
	if cooldown > 0:
		cooldown -= delta
	
	timer -= delta
	if timer > 0 and timer < 1:
		get_tree().reload_current_scene()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		cancel()


func pickup(card: Card, zone: Zone):
	if held_card \
	or cooldown > 0 \
	or zone.type == Zone.Type.ENEMY \
	or zone.type ==  Zone.Type.ENEMY_HAND:
		return
	
	held_card = card
	card.state = Card.State.FLOATING
	card.z_index = 10
	card.reparent(self)
	cooldown = COOLDOWN


func cancel():
	if !held_card: return
	
	held_card.state = Card.State.ZONE
	held_card.z_index = 2
	held_card.reparent(held_card.parent_zone)
	held_card.parent_zone.refresh()
	held_card = null


func drop(zone: Zone):
	if !held_card \
	or cooldown > 0 \
	or zone.type != Zone.Type.PLAYER:
		return
	
	if held_card.parent_zone == zone:
		cancel()
		return
	
	held_card.state = Card.State.ZONE
	held_card.z_index = 2
	
	var card_index = held_card.parent_zone.cards.find(held_card)
	held_card.parent_zone.cards.pop_at(card_index)
	held_card.parent_zone.refresh()
	held_card.reparent(zone)
	zone.cards.append(held_card)
	zone.refresh()
	
	var start = Vector2i(
		int(str(held_card.parent_zone.name)[5]),
		card_index
	)
	var end = int(str(zone.name)[5])
	move(Move.new(start, end))
	try_end_game()
	
	enemy_move(move_search(1))
	try_end_game()
	
	held_card.parent_zone = zone
	
	held_card = null
	cooldown = COOLDOWN


func try_end_game():
	var win_check = win_check()
	var label = main.get_node("EndMessage/RichTextLabel") as RichTextLabel
	
	if win_check == INF:
		label.text = "You win!"
	elif win_check == -INF:
		label.text = "You lose!"
	else:
		return
	
	label.get_parent().z_index = 20
	timer = 10


func enemy_move(move: Move):
	var card = zone_nodes[move.start.x].cards[move.start.y]
	var end_zone = zone_nodes[move.end]
	
	if card.parent_zone == end_zone:
		print("Error: AI moved into same zone")
	
	card.parent_zone.cards.pop_at(move.start.y)
	card.parent_zone.refresh()
	card.reparent(end_zone)
	card.parent_zone = end_zone
	end_zone.cards.append(card)
	end_zone.refresh()
	
	move(move)


func move_search(player: int):
	var moves = generate_moves(player)
	var best_move
	var best_score = -INF
	
	match player:
		0:
			player = 1
		1:
			player = -1
	
	print_state()
	print(moves.size())
	print("++\n")
	for move in moves:
		move(move)
		move.print()
		var eval = evaluate_position() * player
		print(eval)
		if eval > best_score:
			best_score = eval
			best_move = move
		unmove(move)
	
	return best_move


func generate_moves(player: int):
	var moves: Array[Move]
	player *= 4
	
	for i in range(player, player + 4):
		for j in zones[i].size():
			for k in range(player, player + 3):
				if k == i: continue
				moves.append(Move.new(Vector2(i, j), k))
	
	return moves


func evaluate_position():
	var score = win_check() * 100
	
	var p0 = 0
	var p1 = 0
	for i in range(0, 3):
		p0 += 30 - abs(30 - values[i])
	for i in range(4, 7):
		p1 += 30 - abs(30 - values[i])
	
	score += p0 + p1 * -1
	
	return score


func win_check():
	var score: int = 0
	var trading_posts: Array[int]
	trading_posts.resize(3)
	
	for i in trading_posts.size():
		
		if values[i + 4] - values[i] == 5:
			trading_posts[i] = 1
			score += 1
			continue
		if values[i] - values[i + 4] == 5:
			trading_posts[i] = -1
			score += -1
			continue
		
		var is_p0_valid = values[i] >= 25 and values[i] <= 30
		var is_p1_valid = values[i + 4] >= 25 and values[i + 4] <= 30
		
		if is_p0_valid and (!is_p1_valid or values[i + 4] < values[i]):
			trading_posts[i] = 1
			score += 1
			continue
		if is_p1_valid and (!is_p0_valid or values[i] < values[i + 4]):
			trading_posts[i] = -1
			score += -1
			continue
		
		trading_posts[i] = 0
	
	if score == 3: return INF
	if score == -3: return -INF
	if trading_posts[0] != 0 and trading_posts[1] != 0 and trading_posts[2] != 0:
		return score * INF
	
	return score


func move(move: Move):
	zones[move.end].append(zones[move.start.x].pop_at(move.start.y))
	values[move.end] = calc_value(move.end)
	values[move.start.x] = calc_value(move.start.x)


func unmove(move: Move):
	zones[move.start.x].insert(move.start.y, zones[move.end].pop_back())
	values[move.end] = calc_value(move.end)
	values[move.start.x] = calc_value(move.start.x)


func calc_value(id: int):
	var value: int = 0
	
	for i in zones[id].size():
		for j in i:
			if zones[id][i] + zones[id][j] == 10:
				value += 10
		
		value += zones[id][i]
	
	return value


func print_state():
	print("\n===[ State ]===")
	
	for i in zones.size():
		var cards: Array
		
		for card in zone_nodes[i].cards:
			cards.append(card.value)
		
		print(str(i) + " :: " + str(zones[i]) + " :: " + str(values[i]))
		print("  :: " + str(cards) + " :: " + str(zone_nodes[i].value))
	
	print("\n")


class Move:
	var start: Vector2i
	var end: int
	
	func _init(start: Vector2i, end: int):
		self.start = start
		self.end = end
	
	func print():
		print(str(start) + " :: " + str(end))
