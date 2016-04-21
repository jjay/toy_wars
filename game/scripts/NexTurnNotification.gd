
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

signal release


func show(game):
	game.add_child(self)
	find_node("Label").set_text(game.current_player.name)
	find_node("Polygon").set_color(game.current_player.color)
	
func hide():
	get_parent().remove_child(self)


func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("select"):
		hide()
		emit_signal("release")
		