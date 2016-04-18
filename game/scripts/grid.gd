
extends Node2D

export var node_size = Vector2(128, 128)
var grid = {}


func _ready():
	var max_x = 0
	var max_y = 0
	for node in get_children():
		var x = node.get_pos().x / node_size.x
		var y = node.get_pos().y / node_size.y
		if x > max_x:
			max_x = x
		if y > max_y:
			max_y = y
		if !grid.has(x):
			grid[x] = {}
		grid[x][y] = node
	grid["size"] = Vector2(max_x + 1, max_y + 1)
	print(str(grid))
	
