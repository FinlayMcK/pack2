extends ScrollContainer

var dragging := false
var last_pos := Vector2.ZERO
var target_scroll := Vector2.ZERO
var velocity := Vector2.ZERO
@export var smoothness := 3000.0      # Higher = slower movement
@export var friction := 200.0        # How quickly it slows down after swipe

func _ready():
	target_scroll = Vector2(get_h_scroll_bar().value, get_v_scroll_bar().value)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			dragging = true
			last_pos = event.position
			velocity = Vector2.ZERO
		else:
			dragging = false
	
	elif event is InputEventScreenDrag and dragging:
		var delta: Vector2 = event.position - last_pos
		last_pos = event.position
	
		# Update target_scroll based on drag
		target_scroll.x = clamp(target_scroll.x - delta.x, 0, get_h_scroll_bar().max_value)
		target_scroll.y = clamp(target_scroll.y - delta.y, 0, get_v_scroll_bar().max_value)
	
		# Track velocity for momentum (no negative sign)
		velocity = delta / get_process_delta_time()



func _process(delta: float) -> void:
	if not dragging:
		# Apply velocity for smooth deceleration
		target_scroll += velocity * delta
	
		# Reduce velocity gradually
		velocity = velocity.lerp(Vector2.ZERO, friction * delta)
	
		# Stop drifting when very small
		if velocity.length() < 1.0:
			velocity = Vector2.ZERO
	
		# Clamp to scroll limits
		target_scroll.x = clamp(target_scroll.x, 0, get_h_scroll_bar().max_value)
		target_scroll.y = clamp(target_scroll.y, 0, get_v_scroll_bar().max_value)
