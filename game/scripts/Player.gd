
extends Node

var money = 5
var hand = null
var side = 0
var buildings = []
var color

func _init():
	hand = Node2D.new();
	hand.set_scale(Vector2(0.5, 0.5))


func add_card(card_name, update_position=false):
	var card = load("res://cards/" + card_name + ".tscn").instance()
	card.set_name(card_name)
	hand.add_child(card)
	if update_position:
		update_card_positions()

func update_card_positions():
	var i = 0
	for card in hand.get_children():
		card.set_pos(Vector2(i * (256 + 16), 0))
		i += 1

func generate_cards():
	while hand.get_child_count() < 4:
		generate_card()
		
func generate_card():
	var index = floor(rand_range(0, 3))
	add_card(["soldier", "tank", "helicopter"][index])
	update_card_positions()