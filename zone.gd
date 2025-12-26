extends Area2D

class_name Zone


@export var type: Type

var focused: bool = false
var value: int
var cards: Array[Card]

const CARD = preload("res://card.tscn")
const CARD_SPACING: float = 24
const CARDS_OFFSET = Vector2(0, 0)

enum Type {PLAYER, PLAYER_HAND, ENEMY, ENEMY_HAND}


func _ready() -> void:
	if type != Type.PLAYER_HAND and type != Type.ENEMY_HAND: return
	
	for i in 10:
		var card: Card = CARD.instantiate()
		card.value = i + 1
		add_child(card)
		cards.append(card)
		card.parent_zone = self
	
	refresh()


func _input(event: InputEvent) -> void:
	if !focused: return
	if event.is_action_pressed("select") :
		GameManager.drop(self)


func refresh():
	value = 0
	
	cards = card_sort(cards)
	var matches: Array[Card]
	
	for i in cards.size():
		for j in i:
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
		if matches.has(card): continue
		value += card.value
		
		if type == Type.PLAYER or type == Type.PLAYER_HAND:
			card.position = Vector2(0, j * CARD_SPACING)
		elif type == Type.ENEMY or type == Type.ENEMY_HAND:
			card.position = CARDS_OFFSET - Vector2(0, j * CARD_SPACING)
		i += 1
		j += 1
	
	if type != Type.PLAYER_HAND and type != Type.ENEMY_HAND:
		$RichTextLabel.text = str(value)

func card_sort(cards: Array[Card]):
	var output: Array[Card]
	
	for i in cards.size():
		if output.size() == 0:
			output.append(cards[i])
			continue
		
		for j in output.size():
			if cards[i].value > output[j].value:
				output.insert(j, cards[i])
				break
			if j == output.size() - 1:
				output.append(cards[i])
				break
	
	return output


func focus_enter():
	focused = true

func focus_exit():
	focused = false

func _on_mouse_entered() -> void:
	focus_enter()

func _on_mouse_exited() -> void:
	focus_exit()
