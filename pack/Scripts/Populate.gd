@tool
extends EditorScript

func _run():
	populate_cardlist()

func populate_cardlist():
	var folder_paths = {
		"Common": "res://Textures/Cards/Common",
		"Rare": "res://Textures/Cards/Rare",
		"Epic": "res://Textures/Cards/Epic",
		"Legendary": "res://Textures/Cards/Legendary",
		"Champion": "res://Textures/Cards/Champion"
	}

	var new_card_list = CardList.new()
	new_card_list.cards.clear()

	for rarity in folder_paths.keys():
		var rarity_dir = DirAccess.open(folder_paths[rarity])
		if not rarity_dir:
			continue

		rarity_dir.list_dir_begin()
		var elixir_folder = rarity_dir.get_next()

		while elixir_folder != "":
			if rarity_dir.current_is_dir() and elixir_folder != "." and elixir_folder != "..":
				var elixir_path = folder_paths[rarity] + "/" + elixir_folder
				var elixir_value = str(elixir_folder) if elixir_folder.is_valid_int() else -1

				var elixir_dir = DirAccess.open(elixir_path)
				if elixir_dir:
					elixir_dir.list_dir_begin()
					var file_name = elixir_dir.get_next()
					while file_name != "":
						if not elixir_dir.current_is_dir() and file_name.get_extension().to_lower() in ["png", "jpg", "webp"]:
							var texture = load(elixir_path + "/" + file_name)
							if texture:
								var card = CardData.new()
								card.id = file_name.get_basename()
								card.rarity = rarity
								card.elixir = elixir_value
								card.image = texture
								new_card_list.cards.append(card)
						file_name = elixir_dir.get_next()
					elixir_dir.list_dir_end()
			elixir_folder = rarity_dir.get_next()

		rarity_dir.list_dir_end()
	
	var save_path = "res://Textures/CardList.tres"
	var err = ResourceSaver.save(new_card_list, save_path)
	if err == OK:
		print("CardList saved successfully at ", save_path)
	else:
		push_error("Failed to save CardList.tres, error code: %d" % err)
