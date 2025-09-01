# GlobalSave.gd
extends Node

# Save/load data
var cards_data := {}
var Level: int 
var XP: int

func _ready() -> void:
	Level += 1
	load_save()

# Reference to your card list resource
var card_list = preload("res://Textures/CardList.tres")

func save_progress():
	var config = ConfigFile.new()
	config.set_value("stats", "level", Level)
	config.set_value("stats", "xp", XP)
	config.save("user://save_data.cfg")

func load_save():
	var config = ConfigFile.new()
	if config.load("user://save_data.cfg") == OK:
		Level = int(config.get_value("stats", "level", 0))
		XP = int(config.get_value("stats", "xp", 0))

func _refresh() -> void:
	# Reset memory variables
	Level = 1
	XP = 0

	save_progress()
