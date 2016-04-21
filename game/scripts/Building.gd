
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




