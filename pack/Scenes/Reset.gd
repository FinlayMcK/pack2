extends MarginContainer

# Path to the config file
const SAVE_FILE = "user://save_data.cfg"

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	self.connect("gui_input", Callable(self, "_on_gui_input"))

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if FileAccess.file_exists(SAVE_FILE):
			# Get the directory containing the file
			var dir_path = SAVE_FILE.get_base_dir()
			var file_name = SAVE_FILE.get_file()
			
			var dir = DirAccess.open(dir_path)
			if dir:
				var err = dir.remove(file_name)
				if err == OK:
					print("Config file deleted successfully: ", SAVE_FILE)
					Global._refresh()
				else:
					printerr("Failed to delete config file: ", SAVE_FILE)
			else:
				printerr("Failed to open directory: ", dir_path)
		else:
			print("Config file does not exist: ", SAVE_FILE)
			
