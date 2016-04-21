
extends Panel

onready var input = get_node("Input")
onready var connect = get_node("Connect")

func _ready():
	connect.connect("pressed", self, "connect")
	input.connect("text_changed", self, "text_changed")
	input.grab_focus()


func connect():
	if input.get_text() == str():
		set_invalid(true)
		return
	
	var sock = StreamPeerTCP.new()
	sock.connect("127.0.0.1", 1234)
	var data = sock.get_partial_data(1024)
	print("msg: " + str(data[0]) + ", " + str(data[1].size()))
	
	var main = preload("res://main.tscn").instance()
	get_tree().get_root().add_child(main)
	get_parent().remove_child(self)
	

	
func text_changed():
	set_invalid(input.get_text() == str())
		
func set_invalid(value):
	if value:
		input.add_color_override("font_color", Color(1, 0.2, 0.2))
	else:
		input.add_color_override("font_color", Color(0.2, 1, 0.2))
