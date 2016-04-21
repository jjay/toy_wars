
extends Area2D

#export(String, FILE, "*units/*.tscn") var unit
export(PackedScene) var unit
export var cost = 1

onready var game = get_node("/root/Game")
onready var selection = get_node("/root/Game/Selection")

var unit_instance

func _ready():
	unit_instance = unit.instance()

func _input_event( viewport, event, shape_idx ):
	if event.is_action_pressed("select"):
		selection.select_spawn_zones(self, "play", game.spawn_color)

func play(grid_pos):
	unit_instance.owner = game.current_player
	game.units.add_child(unit_instance)
	unit_instance.set_pos(game.level.get_local_pos(grid_pos))
	get_parent().remove_child(self)
	game.current_player.update_card_positions()
	print("Plaing card at " + str(grid_pos))
