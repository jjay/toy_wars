extends Area2D

onready var header = get_node("Header")
onready var body = get_node("Body")
onready var turn_label = get_node("Header/TurnValue")
onready var money_label = get_node("Header/MoneyValue")
onready var time_label = get_node("Header/TimeValue")
onready var text_label = get_node("Body/TextValue")
onready var button = get_node("Body/Button")


func set_text(text):
	text_label.set_text(text)
	
func set_turn(side):
	turn_label.set_text(side)
	
func set_money(value):
	money_label.set_text(str(value))

func set_time(value):
	time_label.set_text(str(value))

func hide_body():
	remove_child(body)
	set_pickable(false)

func show_body():
	add_child(body)
	set_pickable(true)

func hide_header():
	remove_child(header)
	
func show_header():
	add_child(header)
	
func show_button():
	button.show()

func hide_button():
	button.hide()
	

# just block any input
func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("select"):
		return

