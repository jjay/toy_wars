
extends Area2D


export (int, "NEUTRAL", "RADIANT", "DIRE") var owner

onready var game = get_node("/root/Game")
onready var polygon = get_node("Polygon")

func _ready():
	var vars = get_node("/root/const")
	if owner == vars.RADIANT:
		polygon.set_color(game.radiant_color)
		add_to_group("RadiantBuilding")
	elif owner == vars.DIRE:
		polygon.set_color(game.dire_color)
		add_to_group("DireBuilding")
	else:
		polygon.set_color(game.neutral_color)
		add_to_group("NeutralBuilding")
		


func try_capture(player):
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
		if owner != 0:
			game.winner = game.current_player.name
