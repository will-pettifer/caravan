extends Area2D

class_name Zone


@export var type: Type

var focused: bool = false
var value: int
var cards: Array[Card]

const CARD = preload("res://card.tscn")
const CARD_SPACING = 50

enum Type {PLAYER, PLAYER_HAND, ENEMY, ENEMY_HAND}


func _ready() -> void:
	if type != Type.PLAYER_HAND: return
	
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
	cards = card_sort(cards)
	var temp: Array[Card]
	
	for i in cards.size():
		for j in i:
			if cards[i].value + cards[j].value != 10: continue
			temp.append(cards[i])
			temp.append(cards[j])
	
	var i = 0
	var j = 0
	while i < temp.size():
		temp[i].position = Vector2(-15, j * CARD_SPACING)
		temp[i + 1].position = Vector2(15, j * CARD_SPACING)
		i += 2
		j += 1
	
	for card in cards:
		if temp.has(card): continue
		card.position = Vector2(0, j * CARD_SPACING)
		i += 1
		j += 1

func card_sort(cards: Array[Card]):
	var output: Array[Card]
	
	for i in cards.size():
		if output.size() == 0:
			output.append(cards[i])
			continue
		
		for j in output.size():
			if cards[i].value < output[j].value:
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
