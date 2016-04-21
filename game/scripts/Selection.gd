
extends Area2D

onready var level = get_node("../Level")
onready var polygon = get_node("Polygon")
onready var collision = get_node("Collision")
onready var game = get_node("/root/Game")
onready var vars = get_node("/root/const")

var current_selection
var next_action
var current_color

func select_spawn_zones(card, action, color):
	current_selection = card
	next_action = action
	current_color = color
	var player = game.current_player
	var group
	if player.side == vars.RADIANT:
		group = "RadiantBuilding"
	elif player.side == vars.DIRE:
		group = "DireBuilding"

		
	#print("Try to select spawn zones for " + card.get_name())
	#print("Found buildings " + str(get_tree().get_nodes_in_group(group).size()))
	for build in get_tree().get_nodes_in_group(group):
		var moves = find_possible_moves(build.get_pos(), 1, card.unit_instance.unit_type)
		draw_moves(moves)
		update_collision_shape(moves)
		print ("Found moves: " + str(moves))
		

func select_unit(unit, action, color):
	current_selection = unit
	next_action = action
	current_color = color
	
	var moves = find_all_moves(unit)
	#print("moves " + str(moves))
	draw_moves(moves)
	update_collision_shape(moves)

func find_possible_moves(pos, steps, type):
	print("Finding posible moves for " + str(pos) + ", " + str(steps) + ", " + str(type))
	var first = PathFindNode.new()
	first.pos = level.get_grid_pos(pos)
	first.len = 0
	var open = [first]
	var result = []
	var closed = {}
	
	while open.size():
		var current = open[0]
		open.pop_front()
		if closed.has(str(current.pos)):
			continue
		result.append(current.pos)
		closed[str(current.pos)] = true
		for ix in [-1, 0, 1]:
			for iy in [-1, 0, 1]:
				if ix == 0 && iy == 0 || ix != 0 && iy != 0:
					continue
				if current.len >= steps:
					continue
				var next = PathFindNode.new()
				next.len = current.len + 1
				next.pos = Vector2(current.pos.x + ix, current.pos.y + iy)
				if next.pos.x < 0 || next.pos.y < 0 || next.pos.x >= level.grid_size.x || next.pos.y >= level.grid_size.y:
					continue
				
				var tile_type = str(level.grid[next.pos.x][next.pos.y].path_type)
				if str(type) == "Tank" || str(type) == "Soldier":
					if tile_type == "Water":
						continue
				open.append(next)
				
	return result

func find_all_moves(unit, longest_move=10):
	var first = PathFindNode.new()
	first.pos = unit.get_grid_pos()
	first.len = 0
	var open = [first]
	var result = []
	var closed = {}
	
	while open.size():
		var current = open[0]
		open.pop_front()
		if closed.has(str(current.pos)):
			continue
		result.append(current.pos)
		closed[str(current.pos)] = true
		for ix in [-1, 0, 1]:
			for iy in [-1, 0, 1]:
				if ix == 0 && iy == 0 || ix != 0 && iy != 0:
					continue
				if current.len >= min(unit.actions, longest_move):
					continue
				var next = PathFindNode.new()
				next.len = current.len + 1
				next.pos = Vector2(current.pos.x + ix, current.pos.y + iy)
				if next.pos.x < 0 || next.pos.y < 0 || next.pos.x >= level.grid_size.x || next.pos.y >= level.grid_size.y:
					continue
				
				var tile_type = str(level.grid[next.pos.x][next.pos.y].path_type)
				if str(unit.unit_type) == "Tank" || str(unit.unit_type) == "Soldier":
					if tile_type == "Water":
						continue
				
				open.append(next)
				
	return result

func draw_moves(moves):
	# populate all posible vertices
	var half_x = level.node_size.x * 0.5
	var half_y = level.node_size.y * 0.5
	var vertices = {}
	for move in moves:
		var move_verts = [ 
			Vector2(move.x * level.node_size.x, move.y * level.node_size.y),
			Vector2((move.x + 1)* level.node_size.x, move.y * level.node_size.y),
			Vector2((move.x + 1) * level.node_size.x, (move.y + 1) * level.node_size.y),
			Vector2(move.x * level.node_size.x, (move.y + 1) * level.node_size.y),
			Vector2((move.x + 0.5) * level.node_size.x, move.y * level.node_size.y),
			Vector2((move.x + 1)* level.node_size.x, (move.y + 0.5) * level.node_size.y),
			Vector2((move.x + 0.5) * level.node_size.x, (move.y + 1) * level.node_size.y),
			Vector2(move.x * level.node_size.x, (move.y + 0.5) * level.node_size.y)
		]
		for move_vert in move_verts:
			if vertices.has(move_vert):
				vertices[move_vert] += 1
			else:
				vertices[move_vert] = 1
		
	# erase inner corner and half-side vertices
	var erase = []
	for vert in vertices:
		if vertices[vert] > 3:
			erase.append(vert)
		elif vertices[vert] == 2:
			if int(vert.x) % int(level.node_size.x) != 0:
				erase.append(vert)
			elif int(vert.y) % int(level.node_size.y) != 0:
				erase.append(vert)
	for vert in erase:
		vertices.erase(vert)

	# order vertices
	var result = Vector2Array()
	var current
	var first
	var current_weight = 0
	for vert in vertices:
		if vertices[vert] > 1:
			current = vert
			break
	var i = 0
	while vertices.size() > 0:
		i += 1
		if i >= 1000:
			print("endless loop")
			break
		result.push_back(current)
		vertices.erase(current)
		for vert in vertices:
			var dx = abs(current.x - vert.x)
			var dy = abs(current.y - vert.y)
			if dx == 0 && dy == half_y || dy == 0 && dx == half_x:
				current = vert
				break
				
	polygon.set_polygon(result)
	polygon.set_color(current_color)

		

func update_collision_shape(moves):
	var size_x = level.node_size.x
	var size_y = level.node_size.y
	clear_shapes()
	
	for move in moves:
		var verts = Vector2Array([
			Vector2(move.x * size_x, move.y * size_y),
			Vector2((move.x + 1)* size_x, move.y * size_y),
			Vector2((move.x + 1) * size_x, (move.y + 1) * size_y),
			Vector2(move.x * size_x, (move.y + 1) * size_y)
		])
		var shape = ConvexPolygonShape2D.new()
		shape.set_point_cloud(verts)
		add_shape(shape)
		
func clear_selection():
	current_selection = null
	polygon.set_polygon(Vector2Array())
	clear_shapes()
	
func _input_event(viewport, ev, shape_idx):
	if current_selection == null:
		return
	if ev.is_action_pressed("select"):
		current_selection.call(next_action, level.get_grid_pos(ev.pos))
		clear_selection()


class PathFindNode:
	var len = 0
	var pos = Vector2(0, 0)

	

	
	


