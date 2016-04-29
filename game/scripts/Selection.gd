
extends Area2D

onready var game = get_node("/root/Game")
onready var vars = get_node("/root/const")

var current_selection
var next_action
var current_color
var selection_polygons = []
var draw_radius = false

func _draw():
	if current_selection != null && draw_radius:
		draw_circle(current_selection.get_pos(),\
			current_selection.card.radius * game.level.node_size.x,\
			game.hit_radius_color\
		)

func select_spawn_zones(card, action, color):
	clear_selection()
	current_selection = card
	next_action = action
	current_color = color

	var group = game.active_player.side.to_lower() + "_building"
	var moves = []
	for build in get_tree().get_nodes_in_group(group):
		for move in game.level.find_possible_moves(build.get_pos(), 1, card.unit_instance.unit_type):
			moves.append(move)
	draw_moves(moves)
	update_collision_shape(moves)

func select_unit(unit, action, color):
	clear_selection()
	unit.get_node("AnimationPlayer").play("selected")
	current_selection = unit
	next_action = action
	current_color = color
	
	var moves = game.level.find_possible_moves(unit.get_pos(), unit.card.moves, unit.unit_type)
	#print("moves " + str(moves))
	draw_moves(moves)
	update_collision_shape(moves)

func select_target(unit, action, color):
	clear_selection()

	current_selection = unit
	next_action = action
	current_color = color
	
	draw_radius = true
	update()
	
	var targets = []
	for target in get_tree().get_nodes_in_group("Unit"):
		if target.owner == game.active_player:
			continue
		if unit.get_grid_pos().distance_to(target.get_grid_pos()) > unit.card.radius:
			continue
		targets.append(target.get_grid_pos())
		target.health_bar.show()
		target.health_bar.set_damage_value(unit.card.attack)
		
		
	draw_moves(targets)
	update_collision_shape(targets)


func draw_moves(moves):
	var tile = preload("res://scenes/selection_tile.tscn")
	for move in moves:
		var tile_instance = tile.instance()
		add_child(tile_instance)
		tile_instance.set_color(current_color)
		tile_instance.set_pos(game.level.get_local_pos(move))
		selection_polygons.append(tile_instance)
		


func update_collision_shape(moves):
	var size_x = game.level.node_size.x
	var size_y = game.level.node_size.y
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
	draw_radius = false
	update()
	
	if current_selection != null:
		var player = current_selection.get_node("AnimationPlayer")
		if player != null:
			player.stop()
	current_selection = null
	clear_shapes()
	for tile in selection_polygons:
		remove_child(tile)
	for unit in get_tree().get_nodes_in_group("Unit"):
		unit.health_bar.set_damage_value(0)
	selection_polygons.clear()	
	
	
func _input_event(viewport, ev, shape_idx):
	if current_selection == null:
		return
	if ev.is_action_pressed("select"):
		var target = current_selection
		var action = next_action
		var grid_pos = game.level.get_grid_pos(ev.pos)
		clear_selection()
		target.call(action, grid_pos)


