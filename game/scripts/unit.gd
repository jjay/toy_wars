
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

#func _ready():
#	set_process_input(true)

onready var level = get_node("../Level")


func _input_event(viewport, ev, shape_idx):
	if ev.is_action_pressed("select"):
		
		var x = floor(get_pos().x / level.node_size.x)
		var y = floor(get_pos().y / level.node_size.y)
		print("selected " + get_name() + " " + str(x) + ", " + str(y) + " - " + level.grid[x][y].path_type)




