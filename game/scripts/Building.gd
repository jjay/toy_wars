
extends Area2D


export (String, "Neutral", "Radiant", "Dire") var owner

var current_owner = null

onready var game = get_node("/root/Game")
onready var polygon = get_node("Polygon")

func _ready():
	polygon.set_color(game.get(owner.to_lower() + "_color"))
	add_to_group(owner + "Building")
	add_to_group("Building")
	current_owner = game.get(owner.to_lower() + "_player")


func try_capture(player):
	if player == current_owner:
		return
		
	var grid_pos = game.level.get_grid_pos(get_pos())
	var enemy = 0
	var ally = 0
	for unit in get_tree().get_nodes_in_group("Unit"):
		if unit.get_grid_pos().distance_squared_to(grid_pos) <= 1:
			if unit.owner == player:
				ally += 1
			else:
				enemy += 1
	if ally > 0 && enemy == 0:
		print(player.name + " captured building")
		remove_from_group("RadiantBuilding")
		remove_from_group("DireBuilding")
		add_to_group(player.name + "Building")
		polygon.set_color(player.color)
		print("Owner " + str(owner))
		if owner != "Neutral":
			game.winner = player.name
