
extends Polygon2D

onready var level = get_node("../Level")

func set_selection(unit):
	var x = floor(unit.get_pos().x / level.node_size.x)
	var y = floor(unit.get_pos().y / level.node_size.y)
	var moves = find_all_moves(x, y)
	print("res: " + str(moves))
	draw_moves(moves)

	

func find_all_moves(x, y):
	var first = PathFindNode.new()
	first.pos = Vector2(x, y)
	first.len = 0
	var open = [first]
	var result = []
	var closed = []
	
	while open.size():
		var current = open[0]
		open.pop_front()
		result.append(current.pos)
		for ix in [-1, 0, 1]:
			for iy in [-1, 0, 1]:
				if ix == 0 && iy == 0 || ix != 0 && iy != 0:
					continue
				if current.len == 2:
					continue
				var next = PathFindNode.new()
				next.len = current.len + 1
				next.pos = Vector2(current.pos.x + ix, current.pos.y + iy)
				if closed.find(hash(next.pos)) >= 0:
					continue
				if next.pos.x < 0 || next.pos.y < 0 || next.pos.x >= level.grid["size"].x || next.pos.y >= level.grid["size"].y:
					continue
				print("adding " + str(next.pos) + ", " + str(result.find(next.pos)))
				closed.append(hash(next.pos))
				open.append(next)
	return result

func draw_moves(moves):
	# populate all posible vertices
	var vertices = {}
	for move in moves:
		var move_verts = [ 
			Vector2(move.x * level.node_size.x, move.y * level.node_size.y),
			Vector2((move.x + 1)* level.node_size.x, move.y * level.node_size.y),
			Vector2((move.x + 1) * level.node_size.x, (move.y + 1) * level.node_size.y),
			Vector2(move.x * level.node_size.x, (move.y + 1) * level.node_size.y)
		]
		for move_vert in move_verts:
			if vertices.has(move_vert):
				vertices[move_vert] += 1
			else:
				vertices[move_vert] = 1
		
	# erase inner vertices
	var erase = []
	for vert in vertices:
		if vertices[vert] > 3:
			erase.append(vert)
	for vert in erase:
		vertices.erase(vert)

	# order vertices
	var result = Vector2Array()
	var current
	var first
	var prev
	for vert in vertices:
		if vertices[vert] <= 3:
			current = vert
			first = vert
			prev = vert
			break
	var i = 0
	while result.size() == 0 || current != first:
		i += 1
		if i >= 1000:
			print("endless loop")
			break
		result.push_back(current)
		for vert in vertices:
			var dx = abs(current.x - vert.x)
			var dy = abs(current.y - vert.y)
			if dx == 0 && dy == level.node_size.y || dy == 0 && dx == level.node_size.x:
				if vert == prev:
					continue
				prev = current
				current = vert
				vertices.erase(vert)
				break
				
	set_polygon(result)
	update()
	


class PathFindNode:
	var len = 0
	var pos = Vector2(0, 0)

	

	
	


