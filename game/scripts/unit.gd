extends Area2D

export(String, "Soldier", "Helicopter", "Tank") var unit_type

onready var game = get_node("/root/Game")
onready var polygon = get_node("Polygon")
onready var health_bar = get_node("HealthBar")
var can_move = true
var can_attack = true
var owner
var card
var lifes = 0
var selection_state = "move"

signal deselected

func _ready():
	add_to_group("Unit")
	polygon.set_color(owner.color)
	health_bar.set_total_life(card.defence)
	health_bar.set_damage_value(0)
	health_bar.set_missed_life(0)



func _input_event(viewport, ev, shape_idx):
	if !owner.is_active:
		return
	if ev.is_action_pressed("select"):
		if can_move:
			select_move()
		elif can_attack:
			select_attack()

				
func get_grid_pos():
	return game.level.get_grid_pos(get_pos())

func set_grid_pos(grid_pos):
	game.level.free_node(get_pos())
	game.level.reserve_grid_node(grid_pos)
	set_pos(game.level.get_local_pos(grid_pos))

func select_move():
	game.selection.select_unit(self, "move_unit", game.move_color)
	
func select_attack():
	game.selection.select_target(self, "attack_target", game.hit_color)

	
func remove():
	game.level.free_node(get_pos())
	get_parent().remove_child(self)
	
func move_unit(grid_pos):
	if grid_pos.distance_to(get_grid_pos()) < 0.1:
		if can_attack:
			call_deferred("select_attack")
		return
		
	can_move = false
	set_grid_pos(grid_pos)
	if owner != null:
		owner.emit_signal("move_unit", self, grid_pos)
		
	if can_attack:
		select_attack()

func attack_target(grid_pos):
	can_attack = false
	var target
	for t in get_tree().get_nodes_in_group("Unit"):
		if t.get_grid_pos().distance_to(grid_pos) < 0.1:
			target = t
			break
	
	target.lifes -= card.attack
	if target.lifes <= 0:
		target.get_parent().remove_child(target)
		game.level.free_grid_node(grid_pos)
	else:
		target.health_bar.add_missed_life(card.attack)
		target.health_bar.set_damage_value(0)
		
	if owner != null:
		owner.emit_signal("hit_unit", self, target)





