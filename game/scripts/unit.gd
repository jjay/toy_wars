extends Area2D

export(String, "Soldier", "Helicopter", "Tank") var unit_type

onready var level = get_node("../Level")
onready var selection = get_node("../Selection")


func _input_event(viewport, ev, shape_idx):
	if ev.is_action_pressed("select"):
		
		var x = floor(get_pos().x / level.node_size.x)
		var y = floor(get_pos().y / level.node_size.y)
		print("selected " + get_name() + " " + str(x) + ", " + str(y) + " - " + level.grid[x][y].path_type)
		print(str(get_node("../Selection")))
		selection.set_selection(self)
		
func get_grid_pos():
	return Vector2(floor(get_pos().x / level.node_size.x), floor(get_pos().y / level.node_size.y))




