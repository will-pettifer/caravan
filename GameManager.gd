extends Node


var held_card: Card
var cooldown: float

const COOLDOWN: float = 0.1


func _process(delta: float) -> void:
	if cooldown > 0:
		cooldown -= delta


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		cancel()


func pickup(card: Card, zone: Zone):
	if held_card or\
	cooldown > 0:# or\
	#zone.type == Zone.Type.ENEMY or\
	#zone.type ==  Zone.Type.ENEMY_HAND:
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
	if !held_card or\
	cooldown > 0:# or\
	#zone.type != Zone.Type.PLAYER:
		return
	
	held_card.state = Card.State.ZONE
	held_card.z_index = 2
	held_card.parent_zone.cards.erase(held_card)
	held_card.parent_zone.refresh()
	held_card.reparent(zone)
	
	if held_card.parent_zone != zone:
		held_card.parent_zone = zone
		# Next turn
	
	zone.cards.append(held_card)
	zone.refresh()
	held_card = null
	cooldown = COOLDOWN
