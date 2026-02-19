class_name Zone
extends Area2D


@export var type: Type

var game_manager: GameManager
var focused := false
var value: int
var cards: Array[Card]
var is_winning = false
var timer = 0

const CARD := preload("res://Code/card.tscn")
const CARD_SPACING: float = 24
const CARDS_OFFSET := Vector2(0, 0)

enum Type {PLAYER, PLAYER_HAND, ENEMY, ENEMY_HAND}


func _ready() -> void:
	game_manager = get_parent()
	
	cards.resize(10)
	
	if type != Type.PLAYER_HAND and type != Type.ENEMY_HAND: return
	
	for i in 10:
		var card: Card = CARD.instantiate()
		card.value = i + 1
		add_child(card)
		cards[i] = card
		card.parent_zone = self
	
	refresh()


func _process(delta: float) -> void:
	timer += delta
	if is_winning:
		$Panel.rotation = sin(timer * 3) / 20


func refresh():
	value = 0
	var matches: Array[Card]
	
	for i in cards.size():
		for j in i:
			if !cards[i] or !cards[j]: continue
			if cards[i].value + cards[j].value != 10: continue
			matches.append(cards[i])
			matches.append(cards[j])
	
	var i = 0
	var j = 0
	while i < matches.size():
		value += 20
		
		if type == Type.PLAYER or type == Type.PLAYER_HAND:
			matches[i].position = Vector2(-CARD_SPACING / 2, j * CARD_SPACING)
			matches[i + 1].position = Vector2(CARD_SPACING / 2, j * CARD_SPACING)
		elif type == Type.ENEMY or type == Type.ENEMY_HAND:
			matches[i].position = CARDS_OFFSET - Vector2(CARD_SPACING / 2, j * CARD_SPACING)
			matches[i + 1].position = CARDS_OFFSET - Vector2(-CARD_SPACING / 2, j * CARD_SPACING)
		i += 2
		j += 1
	
	for card in cards:
		if !card: continue
		if matches.has(card): continue
		value += card.value
		
		if type == Type.PLAYER or type == Type.PLAYER_HAND:
			card.position = Vector2(0, j * CARD_SPACING)
		elif type == Type.ENEMY or type == Type.ENEMY_HAND:
			card.position = CARDS_OFFSET - Vector2(0, j * CARD_SPACING)
		i += 1
		j += 1
	
	if type != Type.PLAYER_HAND and type != Type.ENEMY_HAND:
		$Panel/Label.text = str(value)


func win():
	if !is_winning:
		timer = 0
		is_winning = true
	
	var style = load("res://Art/UI/ui_plain.tres").duplicate()
	style.texture = load("res://Art/UI/ui3.png")
	$Panel.add_theme_stylebox_override("panel", style)


func lose():
	is_winning = false
	
	$Panel.rotation = 0
	
	$Panel.remove_theme_stylebox_override("panel")


func focus_enter():
	focused = true
	game_manager.overlapping_objects.append(self)

func focus_exit():
	focused = false
	game_manager.overlapping_objects.erase(self)

func _on_mouse_entered() -> void:
	focus_enter()

func _on_mouse_exited() -> void:
	focus_exit()


func print():
	var card_array: Array
	for card in cards:
		card_array.append(card.value)
	print(card_array)
