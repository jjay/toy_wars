extends Area2D

export(String, "Soldier", "Helicopter", "Tank") var unit_type
export var actions = 1

onready var level = get_node("../Level")
onready var selection = get_node("../Selection")


func _input_event(viewport, ev, shape_idx):
	if ev.is_action_pressed("select"):
		selection.select_unit(self, "move_unit", get_parent().move_color)
		
func get_grid_pos():
	return level.get_grid_pos(get_pos())
	
func move_unit(grid_pos):
	set_pos(level.get_local_pos(grid_pos))




