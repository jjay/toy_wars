
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

signal release
var has_winner = false


func show(game):
	game.add_child(self)
	find_node("Polygon").set_color(game.current_player.color)
	var winner = game.get_winner()
	if winner == null:
		find_node("Label").set_text(game.current_player.get_name())
	else:
		find_node("Label").set_text(game.current_player.get_name() + " WIN!")
		has_winner = true
	
func hide():
	get_parent().remove_child(self)


func _input_event(viewport, event, shape_idx):
	if has_winner:
		return
	if event.is_action_pressed("select"):
		hide()
		emit_signal("release")
		