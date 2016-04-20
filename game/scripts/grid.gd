
extends Node2D

export var node_size = Vector2(128, 128)
var grid = []
var grid_size = Vector2(0, 0)


func _ready():
	var max_x = 0
	var max_y = 0
	for node in get_children():
		var x = floor(node.get_pos().x / node_size.x)
		var y = floor(node.get_pos().y / node_size.y)
		if x > max_x:
			max_x = x
		if y > max_y:
			max_y = y
		grid.resize(max(grid.size(), x+1))
		if grid[x] == null:
			grid[x] = []
		grid[x].resize(max(grid[x].size(), y+1))
		grid[x][y] = node
	grid_size = Vector2(max_x + 1, max_y + 1)
	print("Level scaned: " + str(grid_size.x) + "x" + str(grid_size.y))
	
func get_grid_pos(local_pos):
	return Vector2(\
		floor(local_pos.x / node_size.x),\
		floor(local_pos.y/ node_size.y)\
	)	

func get_local_pos(grid_pos):
	return Vector2(\
		(0.5 + grid_pos.x) * node_size.x,\
		(0.5 + grid_pos.y) * node_size.y\
	)