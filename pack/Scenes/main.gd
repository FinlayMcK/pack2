extends Node2D

@onready var Storage = $Pages/Storage
@onready var Peel = $Pages/Peel
@onready var Settings = $Pages/Settings

@onready var XP =  $Top/MarginContainer/MarginContainer/ProgressBar/XP
@onready var Level = $Top/MarginContainer/MarginContainer/ProgressBar/Level
@onready var XpProg = $Top/MarginContainer/MarginContainer/ProgressBar

@onready var storage_button = $NavBar/HBoxContainer/Cards
@onready var peel_button = $NavBar/HBoxContainer/Peel
@onready var settings_button = $NavBar/HBoxContainer/Settings

var canswitch: bool = true


var currentScene := 2 # start on Peel
const PAGE_WIDTH := 1196

func _ready() -> void:
	for button in [storage_button, peel_button, settings_button]:
		_set_pivot_to_center(button)

	# Make sure the active button is offset at game start
	_update_button_offset()
	_update()


func _set_pivot_to_center(button: Control) -> void:
	button.pivot_offset = button.size / 2

func _update():
	
	while Global.XP >= Global.Level * 5 * 2:
		Global.XP -= Global.Level * 5 * 2
		Global.Level += 1

		
	XP.text = str(Global.XP, " / ", Global.Level * 5 * 2)
	Level.text = str(Global.Level)
	XpProg.value = Global.XP
	XpProg.max_value = Global.Level * 5 * 2
	


func _move_to_scene(targetScene: int) -> void:
	if targetScene == currentScene:
		return
		
	Storage._refresh()
	canswitch = false

	var movedir = (currentScene - targetScene) * PAGE_WIDTH
	currentScene = targetScene
	
	var tween := create_tween()
	
	tween.tween_property(Storage, "position:x", Storage.position.x + movedir, 0.15) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	
	tween.parallel().tween_property(Peel, "position:x", Peel.position.x + movedir, 0.15) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	
	tween.parallel().tween_property(Settings, "position:x", Settings.position.x + movedir, 0.15) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
		
	tween.finished.connect(finmove)
		
	_update_button_offset()
	
func finmove():
	canswitch = true

func _update_button_offset() -> void:
	var tween := create_tween()
	
	# Reset all buttons to their default Y position
	tween.tween_property(storage_button, "position:y", 0, 0.2)
	tween.parallel().tween_property(peel_button, "position:y", 0, 0.2)
	tween.parallel().tween_property(settings_button, "position:y", 0, 0.2)

	# Move the active one up by 20px
	match currentScene:
		1:
			tween.parallel().tween_property(storage_button, "position:y", -20, 0.2)
		2:
			tween.parallel().tween_property(peel_button, "position:y", -20, 0.2)
		3:
			tween.parallel().tween_property(settings_button, "position:y", -20, 0.2)




func _on_storage_button_up() -> void:
	_move_to_scene(1)

func _on_peel_button_up() -> void:
	_move_to_scene(2)

func _on_settings_button_up() -> void:
	_move_to_scene(3)
