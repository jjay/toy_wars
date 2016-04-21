extends Node2D


export(Color) var move_color
export(Color) var hit_color
export(Color) var spawn_color
export(Color) var radiant_color
export(Color) var dire_color
export(Color) var neutral_color

var turn = 0
var timer
var players = [] 
var current_player
var turn_time = 5

onready var hand_container = get_node("HandContainer")
onready var timer_label = get_node("TimerLabel")
onready var player_label = get_node("ActivePlayerLabel")
onready var selection = get_node("Selection")
onready var units = get_node("Units")
onready var level = get_node("Level")
onready var vars = get_node("/root/const")

func _ready():
	print("game rady")
	var p1 = Player.new()
	p1.name = "ВшDire";
	p1.side = vars.DIRE
	p1.color = dire_color
	p1.generate_cards()
	var p2 = Player.new()
	p2.color = radiant_color
	p2.name = "Radiant";
	p2.generate_cards()

	p1.update_card_positions()
	p2.update_card_positions()
	p2.side = vars.RADIANT
	players.append(p1);
	players.append(p2)
	
	hand_container.add_child(p1.hand)
	
	timer = Timer.new()
	add_child(timer)
	timer.set_one_shot(true)
	#timer.set_wait_time(0)
	timer.connect("timeout", self, "process_turn")
	

	timer.start()
	
	set_process(true)
	process_turn()
	
func process_turn():
	turn += 1
	print("Start turn " + str(turn))
	timer.set_wait_time(turn_time)
	timer.start()
	current_player = players[turn % 2]
	hand_container.remove_child(hand_container.get_child(0))
	hand_container.add_child(current_player.hand)
	player_label.set_text(current_player.name)
	for unit in get_tree().get_nodes_in_group("Unit"):
		unit.can_move = true
	if current_player.hand.get_child_count() < 4:
		current_player.generate_card()

func get_player_by_side(side):
	for p in players:
		print("Check " + p.name + ", " + str(p.side == side))
		if p.side == side:
			return p
	
	
func _process(delta):
	timer_label.set_text(str(int(ceil(timer.get_time_left()))))
	



class Player:
	var name = "Player 1"
	var money = 0
	var hand = null
	var side = 0
	var buildings = []
	var color

	

	func _init():
		hand = Node2D.new();
		hand.set_scale(Vector2(0.5, 0.5))

	
	func add_card(card_name, update_position=false):
		var card = load("res://cards/" + card_name + ".tscn").instance()
		card.set_name(card_name)
		hand.add_child(card)
		if update_position:
			update_card_positions()
	
	func update_card_positions():
		var i = 0
		for card in hand.get_children():
			card.set_pos(Vector2(i * (256 + 16), 0))
			i += 1
	
	func generate_cards():
		while hand.get_child_count() < 4:
			generate_card()
			
	func generate_card():
		var index = floor(rand_range(0, 3))
		add_card(["soldier", "tank", "helicopter"][index])
		update_card_positions()
			

		
	
	