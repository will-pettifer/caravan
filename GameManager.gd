extends Node


var held_card: Card
var cooldown: float

const COOLDOWN: float = 0.1


func _process(delta: float) -> void:
	if cooldown > 0:
		cooldown -= delta


func pickup(card: Card, zone: Zone):
	if held_card or\
	cooldown > 0 or\
	zone.type == Zone.Type.ENEMY or\
	zone.type ==  Zone.Type.ENEMY_HAND:
		return
	
	held_card = card
	card.state = Card.State.FLOATING
	card.z_index = 10
	card.reparent(self)
	zone.cards.erase(card)
	cooldown = COOLDOWN


func drop(zone: Zone):
	if !held_card or\
	cooldown > 0 or\
	zone.type != Zone.Type.PLAYER:
		return
	
	held_card.reparent(zone)
	zone.cards.append(held_card)
	zone.refresh()
	held_card.state = Card.State.ZONE
	held_card.z_index = 2
	held_card.parent_zone.refresh()
	held_card.parent_zone = zone
	held_card = null
	cooldown = COOLDOWN
