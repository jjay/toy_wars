extends Node2D


export(Color) var move_color
export(Color) var hit_color
export(Color) var hit_radius_color
export(Color) var spawn_color
export(Color) var radiant_color
export(Color) var dire_color
export(Color) var neutral_color
export(int) var turn_time = 5
export(int) var max_turns = 10

var turn = 0
var timer
var players = [] 
var radiant_player
var dire_player
var current_player
var next_turn_screen
var winner = null


onready var hand_container = get_node("HandContainer")
onready var timer_label = get_node("TimerLabel")
onready var player_label = get_node("ActivePlayerLabel")
onready var selection = get_node("Selection")
onready var units = get_node("Units")
onready var level = get_node("Level")
onready var vars = get_node("/root/const")

func _init():
	var player_class = preload("res://scripts/Player.gd")
	print("game init")
	dire_player = player_class.new()
	dire_player.set_name("Dire");
	add_child(dire_player)
	dire_player.generate_cards()
	dire_player.update_card_positions()
	
	radiant_player = player_class.new()
	radiant_player.set_name("Radiant")
	radiant_player.generate_cards()
	radiant_player.update_card_positions()

	players.append(dire_player);
	players.append(radiant_player)


	
func _ready():
	dire_player.color = dire_color	
	radiant_player.color = radiant_color
	hand_container.add_child(dire_player.hand)
	next_turn_screen = preload("res://scenes/next_turn_notification.tscn").instance()
	timer = Timer.new()
	add_child(timer)
	timer.set_one_shot(true)
	#timer.set_wait_time(0)
	timer.connect("timeout", self, "process_turn")
	set_process(true)
	process_turn()
	
func process_turn():
	turn += 1
	print("Start turn " + str(turn))
	current_player = players[turn % 2]
	selection.clear_selection()

	
	hand_container.remove_child(hand_container.get_child(0))
	hand_container.add_child(current_player.hand)

	for unit in get_tree().get_nodes_in_group("Unit"):
		unit.can_move = true
		unit.can_attack = true
	if current_player.hand.get_child_count() < 4:
		current_player.generate_card()
	for building in get_tree().get_nodes_in_group("Building"):
		building.try_capture(current_player)
	for building in get_tree().get_nodes_in_group(current_player.get_name() + "Building"):
		current_player.money += 1
		
	next_turn_screen.show(self)
	
	update_texts()
	
	yield(next_turn_screen, "release")
	timer.set_wait_time(turn_time)
	timer.start()
		
func get_winner():
	if winner != null:
		return winner
	if turn < max_turns:
		return null
	var radiant = get_tree().get_nodes_in_group("RadiantBuilding").size()
	var dire = get_tree().get_nodes_in_group("DireBuilding").size()
	print("Get winner " + str(radiant) + " " + str(dire) + " " + str(turn) + " " + str(max_turns))
	if radiant > dire:
		return "Radiant"
	if dire > radiant:
		return "Dire"
	return null
		
func update_texts():
	player_label.set_text(current_player.get_name() + " " + str(current_player.money))

func get_player_by_side(side):
	for p in players:
		print("Check " + p.get_name() + ", " + str(p.side == side))
		if p.side == side:
			return p
	
	
func _process(delta):
	timer_label.set_text(str(int(ceil(timer.get_time_left()))))
	




	