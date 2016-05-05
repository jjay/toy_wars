
extends Area2D

#export(String, FILE, "*units/*.tscn") var unit
export(PackedScene) var unit
export var cost = 1
export var attack = 1
export var defence = 1
export var radius = 1
export var moves = 1

onready var game = get_node("/root/Game")
onready var attack_label = get_node("Attack")
onready var defence_label = get_node("Defence")
onready var cost_label = get_node("Cost")

var resource_path
var unit_instance
var player

static func Create(path, player, unit_name=null):
	var card = load(path).instance()
	card.setup(player, unit_name)
	card.resource_path = path
	return card

	

func setup(the_owner=null, unit_name=null):
	if unit_instance != null:
		return
	print("Setup player for card: " + str(the_owner) + ", " + str(unit_instance))	
	player = the_owner
	unit_instance = unit.instance()
	unit_instance.card = self
	unit_instance.lifes = defence
	unit_instance.owner = the_owner
	if unit_name != null:
		unit_instance.set_name(unit_name)
	
func _ready():
	setup()
	cost_label.set_text(str(cost))
	attack_label.set_text(str(attack))
	defence_label.set_text(str(defence))

var drag = null
func _input_event( viewport, event, shape_idx ):
	#print("_input_event")
	#if drag != null:
	#	return
	#if event.type == InputEvent.MOUSE_BUTTON && event.is_pressed():
	#	drag = Node2D.new()
	#	get_parent().add_child(drag)
	#	drag.set_pos(get_pos())
	#	set_process_input(true)
	#return
	
	if !player.is_active:
		return
	if cost > player.money:
		return
	if event.is_action_pressed("select"):
		game.selection.select_spawn_zones(self, "play", game.spawn_color)

func _input(event):
	print("_input")
	if drag == null:
		return
	if event.type  == InputEvent.MOUSE_MOTION:
		translate(event.relative_pos)
	if event.type == InputEvent.MOUSE_BUTTON && !event.is_pressed():
		get_parent().remove_child(drag)
		drag = null
		set_process_input(false)


func play(grid_pos):
	game.active_player.money -= cost
	unit_instance.owner = game.active_player
	unit_instance.set_name("Unit" + str(game.generate_id()))
	game.units.add_child(unit_instance)
	unit_instance.set_pos(game.level.get_local_pos(grid_pos))
	get_parent().remove_child(self)
	game.active_player.update_card_positions()
	game.level.reserve_grid_node(grid_pos)
	unit_instance.select_move()
	player.emit_signal("play_card", self, grid_pos)
	print("Plaing card at " + str(grid_pos))
	
	