
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
		print("check " + str(x) + ", " + str(y) + ", " + str(node.get_pos()))
		grid.resize(max(grid.size(), x+1))
		if grid[x] == null:
			grid[x] = []
		grid[x].resize(max(grid[x].size(), y+1))
		grid[x][y] = node
	grid_size = Vector2(max_x + 1, max_y + 1)
	print(str(grid))
	