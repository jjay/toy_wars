
extends "BasePlayer.gd"

var money = 5
var hand = null
var buildings = []
var deck = null

const DECKS = [
	["soldier", "soldier", "soldier", "soldier", "tank", "tank", "tank", "helicopter"],
	["soldier", "soldier", "soldier", "tank", "tank", "tank", "helicopter", "helicopter"],
	["soldier", "soldier", "tank", "tank", "helicopter", "helicopter", "helicopter", "helicopter"]
]	


func _init():
	hand = Node2D.new();
	hand.set_scale(Vector2(0.5, 0.5))
	randomize()
	deck = DECKS[floor(rand_range(0, DECKS.size()))]

func _ready():
	connect("play_card", self, "check_card_costs")


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
	add_card(deck[floor(rand_range(0, deck.size()))])
	update_card_positions()

func opponent_play_card(card, pos):
	var unit = card.unit_instance
	game.units.add_child(unit)
	unit.set_grid_pos(pos)
	
func opponent_move_unit(unit, pos):
	unit.set_grid_pos(pos)
	
func opponent_hit_unit(unit, target):
	target.take_damage(unit.card.attack)

func process_turn():
	generate_cards()
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
	game.end_turn_btn.show()
	yield(game.timer, "timeout")
	game.end_turn_btn.hide()
	emit_signal("end_turn")
	
func force_end_turn():
	game.timer.stop()
	game.timer.emit_signal("timeout")	

func show_win():
	game.gui.hide_header()
	game.gui.show_body()
	game.gui.set_text("You win!")
	game.gui.show_button()

func show_lose():
	game.gui.hide_header()
	game.gui.show_body()
	game.gui.set_text("You LOOOSE!!!!")
	game.gui.hide_button()

func cleanup():
	for child in hand.get_children():
		hand.remove_child(child)

func check_card_costs(card, pos):
	for card in hand.get_children():
		if card.cost > money:
			card.set_opacity(0.5)
		else:
			card.set_opacity(1)