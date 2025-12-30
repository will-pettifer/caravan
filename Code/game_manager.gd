class_name GameManager
extends Node


var held_card: Card
var cooldown: float
var timer: float = 0
var main: Main
var zones: Array
var zone_nodes: Array
var values: Array[int]
var overlapping_objects: Array
var is_paused: bool = true
var p0# := Willow.new(self, 0)
var p1 := Willow.new(self, 1)
var is_player_start: bool = true
var is_game_started: bool = false
var is_game_end: bool = false

const COOLDOWN: float = 0.01


func _ready() -> void:
	main = get_tree().current_scene
	
	# Set up the zones, and add 1-10
	values.resize(8)
	zones.resize(8)
	for i in zones.size():
		zones[i] = []
	
	for i in 10:
		zones[3].append(i + 1)
		zones[7].append(i + 1)
	
	# Link the abstract zones to the visual nodes
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
		zone_nodes[i] = get_node(node_path)


func _input(event: InputEvent) -> void:
	if is_paused or is_game_end: return
	if event.is_action_pressed("select"):
		if overlapping_objects.size() == 0:
			cancel()
			return
		
		var zone: Zone
		var card: Card
		for obj in overlapping_objects:
			if obj is Zone:
				zone = obj
			elif obj is Card:
				card = obj
		
		if !zone:
			cancel()
			return
		if held_card and card:
			if held_card != card:
				cancel()
				pickup(card, zone)
				return
		if held_card:
			drop(zone)
			return
		if card:
			pickup(card, zone)
			return
		
	elif event.is_action_pressed("cancel"):
		cancel()


func start_game():
	if !is_game_started:
		is_paused = false
		is_game_started = true
		if !is_player_start:
			enemy_move(p1.move_search())
	else:
		restart()


func restart():
	main.restart()


func pickup(card: Card, zone: Zone):
	if held_card \
	or zone.type == Zone.Type.ENEMY \
	or zone.type ==  Zone.Type.ENEMY_HAND:
		return
	
	held_card = card
	card.state = Card.State.FLOATING
	card.z_index = 10
	card.reparent(self)
	card.timer = 0
	cooldown = COOLDOWN


func cancel():
	if !held_card: return
	
	held_card.state = Card.State.ZONE
	held_card.z_index = 2
	held_card.reparent(held_card.parent_zone)
	held_card.parent_zone.refresh()
	held_card = null
	
	$PauseMenu/EndMessage.visible = false


func drop(zone: Zone):
	if !held_card \
	or zone.type == Zone.Type.ENEMY \
	or zone.type ==  Zone.Type.ENEMY_HAND:
		return
	
	if held_card.parent_zone == zone or zone.type == Zone.Type.PLAYER_HAND:
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
	
	held_card.parent_zone = zone
	held_card = null
	cooldown = COOLDOWN
	
	# Apply Player and p1 moves
	move(Move.new(start, end))
	if try_end_game():
		return
	enemy_move(p1.move_search())
	if try_end_game():
		return


func try_end_game():
	var win_check = win_check()
	
	if win_check == INF:
		$PauseMenu.end(true)
	elif win_check == -INF:
		$PauseMenu.end(false)
	else:
		return false
	
	is_game_end = true
	
	return true


func enemy_move(move: Move):
	var card = zone_nodes[move.start.x].cards[move.start.y]
	var end_zone = zone_nodes[move.end]
	
	card.parent_zone.cards.pop_at(move.start.y)
	card.parent_zone.refresh()
	card.reparent(end_zone)
	card.parent_zone = end_zone
	end_zone.cards.append(card)
	end_zone.refresh()
	
	move(move)


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
