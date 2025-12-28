extends Node


var held_card: Card
var cooldown: float
var main
var zones: Array
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


func _process(delta: float) -> void:
	if cooldown > 0:
		cooldown -= delta


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		cancel()


func pickup(card: Card, zone: Zone):
	if held_card \
	or cooldown > 0:# \
	#or zone.type == Zone.Type.ENEMY \
	#or zone.type ==  Zone.Type.ENEMY_HAND:
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
	or cooldown > 0:# \
	#or zone.type != Zone.Type.PLAYER:
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
	print(evaluate_position(1))
	
	held_card.parent_zone = zone
	
	held_card = null
	cooldown = COOLDOWN


func setup_zone_arrays():
	for i in 8:
		zones[i].clear()
		
		var mod
		match i:
			0, 1, 2:
				mod = "P" + str(i)
			3, 4, 5:
				mod = "E" + str(i)
			6:
				mod = "PHand"
			7:
				mod = "EHand"
		
		var node_path = "Zone" + mod
		var zone = main.get_node(node_path)
		for j in zone.cards.size():
			zones[i].append(zone.cards[j].value)


func move_search(player: int):
	var moves = generate_moves(player)
	var best_move
	var best_score = -INF
	
	for move in moves:
		move(move)
		if evaluate_position() * player > best_score:
			best_move = move
		unmove(move)


func generate_moves(player: int):
	var moves: Array[Move]
	player *= 4
	
	for i in range(player, player + 4):
		for j in zones[i].size():
			for k in range(player, player + 3):
				if k == i: continue
				moves.append(Move.new(Vector2(i, j), k))
	
	return moves


func evaluate_position(player: int):
	player *= 4
	var score: int = 0
	var trading_posts: Array[int]
	trading_posts.resize(3)
	
	for i in 3:
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
	
	score *= 100
	
	for i in range(0, 3):
		score += values[i]
	for i in range(4, 7):
		score -= values[i]
		print(str(i) + "///")
	
	return score


func move(move: Move):
	zones[move.end].append(zones[move.start.x].pop_at(move.start.y))
	values[move.end] = calc_value(move.end)
	values[move.start.x] = calc_value(move.start.x)


func unmove(move: Move):
	zones[move.start.x].append(zones[move.end].pop_back())
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


class Move:
	var start: Vector2i
	var end: int
	
	func _init(start: Vector2i, end: int):
		self.start = start
		self.end = end
