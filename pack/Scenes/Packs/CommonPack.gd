extends Node2D

@onready var slider = $"../HSlider"
@onready var Pack = self
@onready var collection_scene = $"../../Storage"
@onready var unlocked_display = $"../CenterContainer/TextureRect"
@onready var Unlocked = $"../Unlocked"

var auto: bool = false
var pack_start_pos: Vector2

var card_start_pos: Vector2

var current_card = null   # card currently displayed
var next_card = null      # card to show after reset

var can_reset: bool = false
var tapped: bool = false

var tween: Tween = null  # persistent tween for Pack/Glow animations
@onready var goup: bool = false

# -------------------------
# READY
# -------------------------
func _ready():
	pack_start_pos = Pack.position
	card_start_pos = unlocked_display.position

	_choose_next_card()
	current_card = next_card
	_spawn_current_card()
	_choose_next_card()

# -------------------------
# PROCESS
# -------------------------
func _process(delta: float) -> void:
	if auto:
		slider.hide()
		if Pack.frame > 0:
			Pack.frame -= 1
		else:
			auto = false
			_move_pack_down()
			
	else:
		if goup == true:
			if Pack.frame < 59 and Pack.frame > 19:
				Pack.frame += 1

# -------------------------
# INPUT
# -------------------------
func _input(event):
	if can_reset and not slider.visible and event is InputEventScreenTouch and event.pressed:
		tapped = true
		_reset_all()
		
	if event is InputEventScreenTouch:
		if event.pressed:
			goup = false  # Finger just touched the screen
		else:
			goup = true   # Finger released


func _on_h_slider_value_changed(value: float) -> void:
	auto = false
	if value >= 20:
		Pack.frame = int(value)
	else:
		Pack.frame = 19
		auto = true

# -------------------------
# PACK ANIMATION
# -------------------------
func _move_pack_down() -> void:
	_unlock_current_card()
	if tween != null:
		tween.kill()
		tween = null

	tween = create_tween()

	# --- Random shake / rotation ---
	var shake_duration = 0.001  # small steps
	var shake_repeats = 20      # number of shakes
	var original_pos = Pack.position
	var original_rot = Pack.rotation

	for i in range(shake_repeats):
		var offset_x = randf_range(-10, 10)
		var offset_rot = deg_to_rad(randf_range(-1, 1))  # rotate -5 to +5 degrees
		tween.tween_property(Pack, "position", original_pos + Vector2(offset_x, 0), shake_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_delay(i * shake_duration)
		tween.tween_property(Pack, "rotation", offset_rot, shake_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_delay(i * shake_duration)

	# Reset to original after shaking
	tween.tween_property(Pack, "position", original_pos, shake_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_delay(shake_repeats * shake_duration)
	tween.tween_property(Pack, "rotation", original_rot, shake_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_delay(shake_repeats * shake_duration)

	# --- Move pack down and unlocked_display up ---
	tween.parallel().tween_property(Pack, "position:y", Pack.position.y + 1600, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(unlocked_display, "position:y", unlocked_display.position.y - 100, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.finished.connect(_on_move_down_finished)



func _on_move_down_finished() -> void:
	can_reset = true
	_start_auto_reset_timer()
	
	Global.XP += 1
	get_parent().get_parent().get_parent()._update()
	Global.save_progress()

# -------------------------
# UNLOCK LOGIC
# -------------------------
func _unlock_current_card() -> void:
	if current_card != null and not collection_scene.cards_data[current_card.id]["found"]:
		collection_scene.unlock_card(current_card.id)
		
		# Fade in the Unlocked label
		Unlocked.visible = true
		Unlocked.modulate.a = 0  # start fully transparent
		
		var fade_in_tween = Unlocked.create_tween()
		fade_in_tween.tween_property(Unlocked, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


		

# -------------------------
# AUTO RESET
# -------------------------
func _start_auto_reset_timer() -> void:
	var timer = get_tree().create_timer(1.0)
	await timer.timeout
	if can_reset:
		_reset_all()

# -------------------------
# RESET LOGIC
# -------------------------
func _reset_all() -> void:
	if not can_reset:
		return

	can_reset = false
	tapped = false
	auto = false

	# Fade out Unlocked label
	if Unlocked.visible:
		var fade_out_tween = Unlocked.create_tween()
		fade_out_tween.tween_property(Unlocked, "modulate:a", 0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		fade_out_tween.finished.connect(func():
			Unlocked.visible = false
			Unlocked.modulate.a = 1.0  # reset alpha for next use
		)


	if unlocked_display.texture != null:
		var old_card_tween = unlocked_display.create_tween()
		old_card_tween.parallel().tween_property(unlocked_display, "position:y", unlocked_display.position.y - 2000, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		old_card_tween.parallel().tween_property(unlocked_display, "scale", Vector2(0.5, 0.5), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


		old_card_tween.finished.connect(func():
			unlocked_display.visible = false
			unlocked_display.texture = null
			unlocked_display.position = card_start_pos
			unlocked_display.scale = Vector2(1, 1)

			current_card = next_card
			_spawn_current_card()
			_choose_next_card()
		)


	Pack.frame = 59
	slider.value = Pack.frame
	

	tween = create_tween()
	tween.tween_property(Pack, "position", pack_start_pos, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_done_reset)
	
	
func _done_reset():
	slider.show()
	
	
# -------------------------
# CARD SELECTION
# -------------------------
func _choose_next_card():
	if collection_scene == null:
		return
	var cards = collection_scene.card_list.cards
	if cards.is_empty():
		return
	
	# Filter only cards with rarity "Common" (capitalized)
	var common_cards: Array = []
	for card in cards:
		if str(card.rarity).capitalize() == "Common":
			common_cards.append(card)
	
	if common_cards.is_empty():
		print("⚠ No common cards available! Cannot choose next card.")
		next_card = null
		return
	
	# Pick only from common rarity
	next_card = common_cards[randi() % common_cards.size()]


func _spawn_current_card():
	if current_card != null:
		unlocked_display.texture = current_card.image
		unlocked_display.visible = true
		unlocked_display.scale = Vector2(1, 1)
		unlocked_display.position = card_start_pos

		# Set pivot AFTER assigning texture
		unlocked_display.pivot_offset = unlocked_display.size / 2
