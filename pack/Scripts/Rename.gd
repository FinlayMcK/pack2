@tool
extends EditorScript

func _run():
	var root_folder = "res://Textures/Cards/"  # Change to your root folder
	rename_images_in_folder(root_folder)
	print("Done!")

func rename_images_in_folder(folder_path: String) -> void:
	var dir = DirAccess.open(folder_path)
	if not dir:
		print("Cannot open folder:", folder_path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name in [".", ".."]:
			file_name = dir.get_next()
			continue

		var full_path = folder_path + "/" + file_name
		if dir.current_is_dir():
			# Recurse into subdirectory
			rename_images_in_folder(full_path)
		else:
			# Only process images
			var ext = file_name.get_extension().to_lower()
			if ext in ["png", "jpg", "jpeg", "gif"]:
				if "Card_" in file_name:
					var new_name = file_name.replace("Card_", "")
					var new_path = folder_path + "/" + new_name
					if not FileAccess.file_exists(new_path):
						var rename_result = dir.rename(file_name, new_name)
						if rename_result == OK:
							print("Renamed:", full_path, "->", new_path)
						else:
							print("Failed to rename:", full_path)
					else:
						print("Skipping (already exists):", new_path)
		file_name = dir.get_next()
	dir.list_dir_end()
