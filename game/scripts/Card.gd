
extends Area2D

#export(String, FILE, "*units/*.tscn") var unit
export(PackedScene) var unit
export var cost = 1

onready var game = get_node("/root/Game")
onready var selection = get_node("/root/Game/Selection")

func _input_event( viewport, event, shape_idx ):
	if event.is_action_pressed("select"):
		selection.select_spawn_zones(self, "play", game.spawn_color)

func play(grid_pos):
	print("Plaing card at " + str(grid_pos))
