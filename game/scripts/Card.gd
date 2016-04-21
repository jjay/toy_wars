
extends Area2D

#export(String, FILE, "*units/*.tscn") var unit
export(PackedScene) var unit
export var cost = 1
export var attack = 1
export var defence = 1
export var radius = 1
export var moves = 1

onready var game = get_node("/root/Game")
onready var selection = get_node("/root/Game/Selection")
onready var attack_label = get_node("Attack")
onready var defence_label = get_node("Defence")
onready var cost_label = get_node("Cost")

var unit_instance

func _ready():
	unit_instance = unit.instance()
	unit_instance.card = self
	unit_instance.lifes = defence
	cost_label.set_text(str(cost))
	attack_label.set_text(str(attack))
	defence_label.set_text(str(defence))

func _input_event( viewport, event, shape_idx ):
	if cost > game.current_player.money:
		return
	if event.is_action_pressed("select"):
		selection.select_spawn_zones(self, "play", game.spawn_color)

func play(grid_pos):
	game.current_player.money -= cost
	game.update_texts()
	unit_instance.owner = game.current_player
	game.units.add_child(unit_instance)
	unit_instance.set_pos(game.level.get_local_pos(grid_pos))
	get_parent().remove_child(self)
	game.current_player.update_card_positions()
	game.level.reserve_grid_node(grid_pos)
	print("Plaing card at " + str(grid_pos))