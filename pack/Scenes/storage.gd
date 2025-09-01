extends Node2D

@onready var grid = $Cards/VBoxContainer/MarginContainer3/GridContainer
@onready var unfoundgrid = $Cards/VBoxContainer/MarginContainer5/GridContainer
var card_scene = preload("res://Scenes/Card.tscn")
var card_list: CardList = preload("res://Textures/CardList.tres")

# Runtime data for each card
var cards_data: Dictionary = {}

var spawned_unfound_cards := {}
var spawned_found_cards := {}
var found_card_order := []

# Load external grayscale shader
var grayscale_material := ShaderMaterial.new()

# Save file path
const SAVE_FILE = "user://card_save.cfg"


func _ready():
	var shader = load("res://Textures/Grayscale.gdshader")
	grayscale_material.shader = shader

	_load_save()

	# Clear grids
	for child in grid.get_children():
		child.queue_free()
	for child in unfoundgrid.get_children():
		child.queue_free()

	# Display cards in **reverse order** of card_list.cards
	for i in range(card_list.cards.size() - 1, -1, -1):
		var card_data = card_list.cards[i]
		if not cards_data.has(card_data.id):
			cards_data[card_data.id] = {
				"level": 1,
				"elixir": card_data.elixir,
				"found": false,
				"ref": card_data
			}
		else:
			cards_data[card_data.id]["ref"] = card_data

		if cards_data[card_data.id]["found"]:
			_spawn_card(card_data, cards_data[card_data.id])
			found_card_order.append(card_data.id)
		else:
			_spawn_card(card_data, cards_data[card_data.id])



# Spawn a single card
func _spawn_card(card_data, runtime):
	if card_data == null:
		push_error("Trying to spawn a card with null reference!")
		return

	if runtime.get("found", false):
		var card_instance = card_scene.instantiate()
		card_instance.card_id = card_data.id
		card_instance.card_image = card_data.image
		card_instance.card_rarity = card_data.rarity
		card_instance.card_level = runtime["level"]
		card_instance.card_elixir = card_data.elixir 
		grid.add_child(card_instance)
	else:
		var image_node = TextureRect.new()
		image_node.texture = card_data.image
		image_node.material = grayscale_material
		image_node.set_meta("card_id", card_data.id)
		unfoundgrid.add_child(image_node)


func unlock_card(card_id):
	if cards_data.has(card_id) and not cards_data[card_id]["found"]:
		cards_data[card_id]["found"] = true
		_save_progress()

		# Remove from unfound grid
		for card in unfoundgrid.get_children():
			if card.get_meta("card_id") == card_id:
				unfoundgrid.remove_child(card)
				card.queue_free()
				break

		# Find the position to insert in the found grid based on reverse array order
		var insert_index = 0
		for i in range(len(card_list.cards) - 1, -1, -1):
			if card_list.cards[i].id == card_id:
				break
			if cards_data[card_list.cards[i].id]["found"]:
				insert_index += 1

		# Spawn and insert at the correct position
		var new_card = cards_data[card_id]["ref"]
		var card_instance = card_scene.instantiate()
		card_instance.card_id = new_card.id
		card_instance.card_image = new_card.image
		card_instance.card_rarity = new_card.rarity
		card_instance.card_level = cards_data[card_id]["level"]
		card_instance.card_elixir = new_card.elixir

		grid.add_child(card_instance)
		grid.move_child(card_instance, insert_index)

		# Update order tracking
		found_card_order.insert(insert_index, card_id)


# Save the found cards and elixir to disk
func _save_progress():
	var config = ConfigFile.new()
	for card_id in cards_data.keys():
		var data = cards_data[card_id]
		config.set_value("cards", str(card_id) + "_found", data["found"])
		config.set_value("cards", str(card_id) + "_elixir", data["elixir"])
	config.save(SAVE_FILE)


# Load the found cards and elixir from disk
func _load_save():
	var config = ConfigFile.new()
	var err = config.load(SAVE_FILE)
	if err == OK:
		for card_resource in card_list.cards:
			var card_id = card_resource.id
			var found = config.get_value("cards", str(card_id) + "_found", false)
			var elixir = config.get_value("cards", str(card_id) + "_elixir", card_resource.elixir)
			cards_data[card_id] = {
				"level": 1,
				"elixir": elixir,
				"found": found,
				"ref": card_resource  # Always store the actual Card object
			}


func _refresh():
	_ready()
