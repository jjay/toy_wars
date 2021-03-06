
extends Node

var color
var is_active = false
var side = "Dire"

signal ready_to_start
signal start_turn
signal end_turn
signal play_card(card, pos)
signal move_unit(unit, pos)
signal hit_unit(unit, target)



onready var game = get_node("/root/Game")


# Radiant|Dire
func set_side(the_side):
	side = the_side
	var prefix = side.to_lower() + "_"
	color = game.get(prefix + "color")

func set_active(value):
	is_active = value

func buildings_count():
	return get_tree().get_nodes_in_group(side.to_lower() + "_building").size()

func opponent_play_card(card, pos):
	pass

func opponent_move_unit(unit, pos):
	pass
	
func opponent_hit_unit(unit, target):
	pass
	
func opponent_ready(side):
	pass
	
func opponent_start_turn():
	pass
	
func opponent_end_turn():
	pass



