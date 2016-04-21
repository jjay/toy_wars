extends Area2D

export(String, "Soldier", "Helicopter", "Tank") var unit_type
export var actions = 1

onready var game = get_node("/root/Game")
onready var polygon = get_node("Polygon")
var can_move = true
var owner

func _ready():
	add_to_group("Unit")
	polygon.set_color(owner.color)
	



func _input_event(viewport, ev, shape_idx):
	if !can_move:
		return
	if owner != game.current_player:
		return
	if ev.is_action_pressed("select"):
		game.selection.select_unit(self, "move_unit", game.move_color)
		
func get_grid_pos():
	return game.level.get_grid_pos(get_pos())
	
func move_unit(grid_pos):
	can_move = false
	set_pos(game.level.get_local_pos(grid_pos))




