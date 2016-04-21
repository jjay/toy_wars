
extends Area2D

onready var level = get_node("../Level")
onready var polygon = get_node("Polygon")
onready var collision = get_node("Collision")
onready var game = get_node("/root/Game")
onready var vars = get_node("/root/const")

var current_selection
var next_action
var current_color
var selection_polygons = []

func select_spawn_zones(card, action, color):
	clear_selection()
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
		var moves = level.find_possible_moves(build.get_pos(), 1, card.unit_instance.unit_type)
		draw_moves(moves)
		update_collision_shape(moves)
		print ("Found moves: " + str(moves))
		

func select_unit(unit, action, color):
	clear_selection()
	unit.get_node("AnimationPlayer").play("selected")
	current_selection = unit
	next_action = action
	current_color = color
	
	var moves = level.find_possible_moves(unit.get_pos(), unit.actions, unit.unit_type)
	#print("moves " + str(moves))
	draw_moves(moves)
	update_collision_shape(moves)





func draw_moves(moves):
	var tile = preload("res://scenes/selection_tile.tscn")
	for move in moves:
		var tile_instance = tile.instance()
		add_child(tile_instance)
		tile_instance.set_color(current_color)
		tile_instance.set_pos(level.get_local_pos(move))
		selection_polygons.append(tile_instance)
		

		

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
	if current_selection != null:
		var player = current_selection.get_node("AnimationPlayer")
		if player != null:
			player.stop()
	current_selection = null
	clear_shapes()
	for tile in selection_polygons:
		remove_child(tile)
	selection_polygons.clear()	
	
	
func _input_event(viewport, ev, shape_idx):
	if current_selection == null:
		return
	if ev.is_action_pressed("select"):
		current_selection.call(next_action, level.get_grid_pos(ev.pos))
		clear_selection()


