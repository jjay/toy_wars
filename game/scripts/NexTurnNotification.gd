
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

signal release
signal player_ready

var press_signal
var has_winner = false
var listen_touch = false
var hide_on_touch = false


func show(game):
	game.add_child(self)
	find_node("Polygon").set_color(game.current_player.color)
	var winner = game.get_winner()
	if winner == null:
		find_node("Label").set_text(game.current_player.get_name())
	else:
		find_node("Label").set_text(game.current_player.get_name() + " WIN!")
		has_winner = true

func set_text(text):
	find_node("Label").set_text(text)

func hide():
	get_parent().remove_child(self)


func _input_event(viewport, event, shape_idx):
	if has_winner:
		return
	if !listen_touch:
		return
	if event.is_action_pressed("select"):
		if hide_on_touch:
			hide()
		emit_signal("release")
		