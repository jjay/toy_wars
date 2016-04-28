extends Node

signal players_ready

export(Color) var move_color
export(Color) var hit_color
export(Color) var hit_radius_color
export(Color) var spawn_color
export(Color) var radiant_color
export(Color) var dire_color
export(Color) var neutral_color

onready var screen = get_node("Screen")
onready var gui = get_node("Screen/GUI")
onready var level = get_node("Screen/Table/Grid")
onready var units = get_node("Screen/Table/Units")
onready var selection = get_node("Screen/Table/Selection")
onready var network = get_node("NetworkConnection")
onready var timer = get_node("Timer")
onready var local_player = get_node("LocalPlayer")
onready var remote_player = get_node("RemotePlayer")

var active_player
var next_unit_id = 1

func _ready():
	print("Game Ready")
	gui.hide_header()
	gui.set_text("Connecting...")
	gui.hide_button()
	yield(remote_player, "connected")
	gui.set_text("Waiting for opponent")
	yield(remote_player, "found")
	gui.set_text("Ready to START!")
	gui.show_button()
	yield(gui.button, "pressed")
	gui.hide_button()
	gui.set_text("Waiting for opponent ready")
	remote_player.opponent_ready()
	var player_side = yield(remote_player, "started")
	gui.hide_body()
	gui.show_header()
	gui.set_turn("Radiant")

	local_player.set_side(player_side)
	local_player.generate_cards()
	screen.get_node("InfoPanel").add_child(local_player.hand)
	
		
	local_player.connect("play_card", remote_player, "opponent_play_card")
	local_player.connect("move_unit", remote_player, "opponent_move_unit")
	local_player.connect("hit_unit", remote_player, "opponent_hit_unit")
	local_player.connect("start_turn", remote_player, "opponent_start_turn")
	local_player.connect("end_turn", remote_player, "opponent_end_turn")
	remote_player.connect("play_card", local_player, "opponent_play_card")
	remote_player.connect("move_unit", local_player, "opponent_move_unit")
	remote_player.connect("hit_unit", local_player, "opponent_hit_unit")
	remote_player.connect("start_turn", local_player, "opponent_start_turn")
	remote_player.connect("end_turn", local_player, "opponent_end_turn")
	
	var players
	if local_player.side == "Radiant":
		players = [local_player, remote_player]
	else:
		players = [remote_player, local_player]
	active_player = players[0]
	active_player.set_active(true)
	emit_signal("players_ready")

	var turn = 0
	while !get_winner():
		selection.clear_selection()
		for unit in get_tree().get_nodes_in_group("Unit"):
			unit.can_move = true
			unit.can_attack = true
		
		active_player.process_turn()
		yield(active_player, "end_turn")
		
		turn += 1
		active_player.set_active(false)
		active_player = players[turn % 2]
		active_player.set_active(true)

func generate_id():
	var id = next_unit_id
	next_unit_id += 1
	return id
	
func get_winner():
	for building in get_tree().get_nodes_in_group("Building"):
		building.try_capture(active_player)
	