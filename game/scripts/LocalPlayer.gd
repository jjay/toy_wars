
extends "BasePlayer.gd"

var money = 5
var hand = null
var buildings = []


func _init():
	hand = Node2D.new();
	hand.set_scale(Vector2(0.5, 0.5))


func add_card(card_name, update_position=false):
	var path = "res://cards/" + card_name + ".tscn"
	var card = preload("res://scripts/Card.gd").Create(path, self)
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
	randomize()
	var index = floor(rand_range(0, 3))
	add_card(["soldier", "tank", "helicopter"][index])
	update_card_positions()

func opponent_play_card(card, pos):
	var unit = card.unit_instance
	game.units.add_child(unit)
	unit.set_grid_pos(pos)
	
func opponent_move_unit(unit, pos):
	unit.set_grid_pos(pos)
	
func opponent_hit_unit(unit, target):
	target.lifes -= unit.card.attack
	if target.lifes <= 0:
		target.remove()
#		game.units.remove_child(target)
	
func process_turn():
	var gui = game.gui
	gui.set_turn("Your")
	gui.show_body()
	gui.show_button()
	gui.set_text("You turn")
	gui.hide_header()
	yield(gui.button, "pressed")
	emit_signal("start_turn")
	gui.hide_body()
	gui.show_header()
	game.timer.start()
	yield(game.timer, "timeout")
	emit_signal("end_turn")
	
	