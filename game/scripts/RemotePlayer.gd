
extends "BasePlayer.gd"

signal connected
signal found
signal started(side)


export var server_host = "127.0.0.1"
export var server_port = 1234

var sock
var buff = ""

func set_active(value):
	pass
	
func _ready():
	sock = StreamPeerTCP.new()
	sock.connect(server_host, server_port)
	set_process(true)
	
func _process(delta):
	var bytes = sock.get_available_bytes()
	if bytes > 0:
		buff += sock.get_string(bytes)
	
	if buff.length() >= 2 && buff.substr(buff.length() - 2, 2) == "\n\n":
		for msg in buff.strip_edges().split("\n\n"):
			process_message(msg)
		buff = ""
		
func process_message(msg):
	var packet = {}
	packet.parse_json(msg)
	print("server>" + str(packet))
	if packet.has("err") && packet["err"] != null:
		print("Server error: " + packet["err"])
	else:
		var method = "_handle_" + packet["msg"]
		if has_method(method):
			callv(method, packet["args"])
		else:
			print("Can't handle method " + method + " (method not found)")


func _handle_info(player_id):
	emit_signal("connected")
	
func _handle_opponent_info(player_id):
	emit_signal("found")

func _handle_start_game(local_player_side):
	print("Emitting start game with " + local_player_side)
	if local_player_side == "Dire":
		set_side("Radiant")
	else:
		set_side("Dire")
	emit_signal("started", local_player_side)
	
func _handle_start_turn():
	emit_signal("start_turn")





func _handle_end_turn():
	emit_signal("end_turn")
	
func send(msg, args=[]):
	var packet = { "msg": msg, "args": args }
	sock.put_utf8_string(packet.to_json() + "\n\n")

func send_to_opponent(msg, args=[]):
	var packet = { "msg": msg, "args": args, "broadcast": true }
	sock.put_utf8_string(packet.to_json() + "\n\n")
	
func opponent_ready():
	send("ready")

#	play_card
#	---------
func opponent_play_card(card, pos):
	var path = card.resource_path
	var name = card.unit_instance.get_name()
	send_to_opponent("play_card", [path, name, pos.x, pos.y])

func _handle_play_card(path, name, x, y):
	game.generate_id()
	var card = preload("res://scripts/Card.gd").Create(path, self, name)
	emit_signal("play_card", card, Vector2(x, y))

# 	move_unit
#   ---------
func opponent_move_unit(unit, pos):
	send_to_opponent("move_unit", [unit.get_name(), pos.x, pos.y])

func _handle_move_unit(name, x, y):
	var unit = game.units.get_node(name)
	emit_signal("move_unit", unit, Vector2(x, y))

#	hit_unit
#	--------	
func opponent_hit_unit(unit, target):
	var unit_name = unit.get_name()
	var target_name = target.get_name()
	send_to_opponent("hit_unit", [unit_name, target_name])

func _handle_hit_unit(unit_name, target_name):
	var unit = game.units.get_node(unit_name)
	var target = game.units.get_node(target_name)
	emit_signal("hit_unit", unit, target)

func opponent_start_turn():
	send_to_opponent("start_turn")
	
func opponent_end_turn():
	send_to_opponent("end_turn")

func process_turn():
	var gui = game.gui
	gui.set_turn("Opponent")
	gui.show_body()
	gui.hide_button()
	gui.hide_header()
	gui.set_text("Opponents turn")
	yield(self, "start_turn")
	gui.hide_body()
	gui.show_header()
	
	
	