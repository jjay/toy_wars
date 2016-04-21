
extends Node2D

export(Color) var move_color
export(Color) var hit_color
export(Color) var spawn_color

var turn = 0
var timer
var players = [] 
var current_player
var turn_time = 5

onready var hand_container = get_node("HandContainer")
onready var timer_label = get_node("TimerLabel")
onready var player_label = get_node("ActivePlayerLabel")

func _ready():
	var p1 = Player.new()
	p1.name = "Player 1";
	p1.add_card("soldier")
	p1.add_card("tank")
	var p2 = Player.new()
	p2.name = "Player 2";
	p2.add_card("soldier")
	p2.add_card("helicopter")
	p1.update_card_positions()
	p2.update_card_positions()
	players.append(p1);
	players.append(p2)
	hand_container.add_child(p1.hand)
	
	timer = Timer.new()
	add_child(timer)
	timer.set_one_shot(true)
	timer.set_wait_time(turn_time)
	timer.connect("timeout", self, "_on_turn_timer")

	timer.start()
	
	set_process(true)
	
func _on_turn_timer():
	turn += 1
	print("Start turn " + str(turn))
	timer.set_wait_time(turn_time)
	timer.start()
	current_player = players[turn % 2]
	hand_container.remove_child(hand_container.get_child(0))
	hand_container.add_child(current_player.hand)
	player_label.set_text(current_player.name)
	
func _process(delta):
	timer_label.set_text(str(int(ceil(timer.get_time_left()))))
	



class Player:
	var name = "Player 1"
	var money = 0
	var hand = null
	
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
		
	
	