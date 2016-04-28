extends Node

signal players_ready

export(Color) var move_color
export(Color) var hit_color
export(Color) var hit_radius_color
export(Color) var spawn_color
export(Color) var radiant_color
export(Color) var dire_color
export(Color) var neutral_color
export(int) var minimum_turns = 10
export(int) var start_money = 6

onready var screen = get_node("Screen")
onready var gui = get_node("Screen/GUI")
onready var level = get_node("Screen/Table/Grid")
onready var units = get_node("Screen/Table/Units")
onready var selection = get_node("Screen/Table/Selection")
onready var end_turn_btn = get_node("Screen/EndTurn")
onready var network = get_node("NetworkConnection")
onready var timer = get_node("Timer")
onready var local_player = get_node("LocalPlayer")
onready var remote_player = get_node("RemotePlayer")

var active_player
var next_unit_id = 1
var winner
var turn = 0

func _ready():
	print("Game Ready")
	gui.hide_header()
	gui.set_text("Connecting...")
	gui.hide_button()
	yield(remote_player, "connected")
	gui.set_text("Waiting for opponent")
	yield(remote_player, "found")
	
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
	end_turn_btn.connect("pressed", local_player, "force_end_turn")
	screen.get_node("InfoPanel").add_child(local_player.hand)
	
	play()
	
func play():
	gui.show_body()
	gui.hide_header()
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
	
	
	
		
	
	
	var players
	if local_player.side == "Radiant":
		players = [local_player, remote_player]
	else:
		players = [remote_player, local_player]
	active_player = players[0]
	active_player.set_active(true)
	emit_signal("players_ready")
	
	turn = 0
	while want_play_more():
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
	
	if local_player == winner:
		local_player.show_win()
		yield(gui.button, "pressed")
		remote_player.opponent_end_turn()
	else:
		local_player.show_lose()
		yield(remote_player, "end_turn")
		
	
	cleanup()
	play()

func cleanup():
	turn = 0
	active_player = null
	winner = null
	local_player.cleanup()
	local_player.money = start_money
	remote_player.cleanup()
	for unit in get_tree().get_nodes_in_group("Unit"):
		units.remove_child(unit)
	
func generate_id():
	var id = next_unit_id
	next_unit_id += 1
	return id
	
func want_play_more():

	for building in get_tree().get_nodes_in_group("building"):
		if building.try_capture(active_player) && building.is_player_base():
			winner = active_player
			return false
	
	var local = get_tree().get_nodes_in_group(local_player.side + "_building").size()
	var remote = get_tree().get_nodes_in_group(remote_player.side + "_building").size()
	local_player.money += local

	if turn >= minimum_turns && local != remote:
		if local > remote:
			winner = local_player
		else:
			winner = remote_player
		return false

	return true
	