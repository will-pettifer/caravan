class_name GameManager
extends Node


@onready var pause_menu = $UILayer/PauseMenu
@onready var end_message = $UILayer/PauseMenu/EndMessage
@onready var ai_out = $UILayer/AIOutput
@onready var ai_out_label = $UILayer/AIOutput/Label

var cooldown: float
var timer: float = 0

var held_card: Card
var main: Main
var p0: AI
var p1 = Willow.new(self, -1)

var position: String
var positions: Array[String]
var zone_nodes: Array
var values: Array[int]
var overlapping_objects: Array
var ai_outcomes: Array

var is_paused: bool = true
var is_input_disabled = true
var is_player_start: bool = false
var is_game_started: bool = false
var is_game_end: bool = false

var thread: Thread
var mutex: Mutex
var semaphore: Semaphore

const COOLDOWN: float = 0.01


func _ready() -> void:
	main = get_tree().current_scene
	
	thread = Thread.new()
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	
	# Set up the zones, and add 1-10
	set_up_position()
	
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

func set_up_position():
	position = "0".repeat(80)
	
	for i in 2:
		for j in 10:
			position[(i * 40 - 10) + j] = char(j + 49)
	
	values.clear()
	values.resize(8)
	
	positions.clear()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next"):
		print(print_pos())
		semaphore.post()
	if is_paused or is_game_end or is_input_disabled: return
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


func _exit_tree():
	thread.wait_to_finish()


func start_game():
	if is_game_started:
		restart()
		return
	
	is_paused = false
	is_game_started = true
	
	if p0:
		ai_out.visible = true
		thread.start(ai_loop)
	else:
		is_input_disabled = false
		enemy_move(p1.random())


func restart():
	main.restart()


func ai_loop():
	var game_count = 100
	for i in game_count:
		set_up_position()
		ai_turn(p0.random())
		ai_turn(p1.random())
		
		while true:
			if ai_turn(p0.move_search()): break
			#semaphore.wait()
			
			if ai_turn(p1.move_search()): break
			#semaphore.wait()
		
		call_deferred("print_ai_outcomes")


func ai_turn(move: Move):
	move(move)
	
	var win_check = win_check()
	if win_check == 0.1:
		ai_outcomes.append("0")
		return true
	if win_check == INF:
		ai_outcomes.append("1")
		return true
	if win_check == -INF:
		ai_outcomes.append("2")
		return true
	
	return false


func ai_opp_turn():
	var move = p1.move_search()
	call_deferred("something", move)


func something(move: Move):
	enemy_move(move)
	refresh_posts()
	if try_end_game():
		return
	
	print(print_pos())
	
	is_input_disabled = false


func print_ai_outcomes():
	var draw_count = 0
	var p0_count = 0
	var p1_count = 0
	
	for out in ai_outcomes:
		match out:
			"0": draw_count += 1
			"1": p0_count += 1
			"2": p1_count += 1
	
	var out = str(p0_count) + " | " + str(draw_count) + " | " + str(p1_count) + "\n\n"
	
	var size = ai_outcomes.size()
	if size > 3: size = 3
	var i = size
	while i > 0:
		if ai_outcomes[-i] == "0":
			out += "draw!\n"
		else:
			out += ("player " + ai_outcomes[-i] + " wins!\n")
		
		i -= 1
	
	ai_out_label.text = out


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
	
	end_message.visible = false


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
	held_card.parent_zone.cards[card_index] = null
	held_card.parent_zone.refresh()
	held_card.reparent(zone)
	if zone.cards[card_index]: print("ERROR: Tried to move into occupied zone")
	zone.cards[card_index] = held_card
	zone.refresh()
	
	var start = int(str(held_card.parent_zone.name)[5]) * 10 + card_index
	var end = int(str(zone.name)[5]) * 10 + card_index
	
	held_card.parent_zone = zone
	held_card = null
	cooldown = COOLDOWN
	
	move(Move.new(start, end))
	refresh_posts()
	if try_end_game():
		return
	
	print(print_pos())
	
	is_input_disabled = true
	
	thread.wait_to_finish()
	thread.start(ai_opp_turn)

func refresh_posts():
	var winning_posts = posts_win_check()
	for i in winning_posts.size():
		match winning_posts[i]:
			1:
				zone_nodes[i].win()
				zone_nodes[i + 4].lose()
			-1:
				zone_nodes[i + 4].win()
				zone_nodes[i].lose()
			0:
				zone_nodes[i].lose()
				zone_nodes[i + 4].lose()


func try_end_game():
	var win_check = win_check()
	
	if win_check == INF:
		pause_menu.end(true)
	elif win_check == -INF:
		pause_menu.end(false)
	else:
		return false
	
	is_game_end = true
	
	return true


func enemy_move(move: Move):
	var card = zone_nodes[move.start / 10].cards[move.start % 10]
	var end_zone = zone_nodes[move.end / 10]
	card.parent_zone.cards[move.start % 10] = null
	card.parent_zone.refresh()
	card.reparent(end_zone)
	card.parent_zone = end_zone
	if end_zone.cards[move.end % 10]: print("ERROR: Tried to move into occupied zone")
	end_zone.cards[move.end % 10] = card
	end_zone.refresh()
	
	move(move)
	refresh_posts()


func win_check():
	var draw_counter = 0
	for pos in positions:
		if position == pos:
			draw_counter += 1
	
	if draw_counter > 3:
		return 0.1
	
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


func posts_win_check():
	var trading_posts: Array[int]
	trading_posts.resize(3)
	
	for i in trading_posts.size():
		
		if values[i + 4] - values[i] == 5:
			trading_posts[i] = 1
			continue
		if values[i] - values[i + 4] == 5:
			trading_posts[i] = -1
			continue
		
		var is_p0_valid = values[i] >= 25 and values[i] <= 30
		var is_p1_valid = values[i + 4] >= 25 and values[i + 4] <= 30
		
		if is_p0_valid and (!is_p1_valid or values[i + 4] < values[i]):
			trading_posts[i] = 1
			continue
		if is_p1_valid and (!is_p0_valid or values[i] < values[i + 4]):
			trading_posts[i] = -1
			continue
		
		trading_posts[i] = 0
	
	return trading_posts


func move(move: Move):
	position[move.end] = position[move.start]
	position[move.start] = str(0)
	values[move.end / 10] = calc_value(move.end)
	values[move.start / 10] = calc_value(move.start)
	
	positions.append(position)


func unmove(move: Move):
	position[move.start] = position[move.end]
	position[move.end] = str(0)
	values[move.end / 10] = calc_value(move.end)
	values[move.start / 10] = calc_value(move.start)
	
	positions.pop_back()


func calc_value(id: int):
	var value: int = 0
	var zone = (id / 10) * 10
	
	for i in 10:
		for j in i:
			if (ord(position[zone + i]) - 48) + (ord(position[zone + j]) - 48) == 10 \
			and position[zone + i] != "0" and position[zone + j] != "0":
				value += 10
		
		value += ord(position[zone + i]) - 48
	
	return value


func print_pos():
	var out = ""
	
	for i in 8:
		out += position.substr(i * 10, 10) + " | " + str(values[i]) + "\n"
		if i == 3:
			out += "-----------|---\n"
	
	return out
