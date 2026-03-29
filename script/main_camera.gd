extends Camera2D

var board_size := Vector2.ZERO
var pan_enabled := true

var panning_mouse := false
var panning_touch := false
var active_touch_id := -1

var last_mouse_pos := Vector2.ZERO
var last_touch_pos := Vector2.ZERO
var pan_velocity := Vector2.ZERO

const PAN_STOP_SPEED := 25.0
const PAN_DAMPING := 2100.0


func _ready() -> void:
	make_current()
	if board_size != Vector2.ZERO:
		position = board_size * 0.5
		_clamp_to_board()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_clamp_to_board()


func _process(delta: float) -> void:
	if not pan_enabled:
		return
	if panning_mouse or panning_touch:
		return

	if pan_velocity.length() > PAN_STOP_SPEED:
		position += pan_velocity * delta
		pan_velocity = pan_velocity.move_toward(Vector2.ZERO, PAN_DAMPING * delta)
		_clamp_to_board()
	else:
		pan_velocity = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if not pan_enabled:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			panning_mouse = true
			last_mouse_pos = event.position
			pan_velocity = Vector2.ZERO
		else:
			panning_mouse = false
	elif event is InputEventMouseMotion:
		if panning_mouse and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var drag_delta: Vector2 = event.position - last_mouse_pos
			if drag_delta != Vector2.ZERO:
				position -= drag_delta
				pan_velocity = -(drag_delta / max(get_process_delta_time(), 0.0001))
				_clamp_to_board()
			last_mouse_pos = event.position
	elif event is InputEventScreenTouch:
		if event.pressed and active_touch_id == -1:
			active_touch_id = event.index
			panning_touch = true
			last_touch_pos = event.position
			pan_velocity = Vector2.ZERO
		elif not event.pressed and event.index == active_touch_id:
			panning_touch = false
			active_touch_id = -1
	elif event is InputEventScreenDrag:
		if panning_touch and event.index == active_touch_id:
			var touch_delta: Vector2 = event.position - last_touch_pos
			if touch_delta != Vector2.ZERO:
				position -= touch_delta
				pan_velocity = -(touch_delta / max(get_process_delta_time(), 0.0001))
				_clamp_to_board()
			last_touch_pos = event.position


func configure_board_size(new_board_size: Vector2) -> void:
	board_size = new_board_size
	if board_size != Vector2.ZERO:
		position = board_size * 0.5
		_clamp_to_board()


func set_pan_enabled(allow_pan: bool) -> void:
	pan_enabled = allow_pan
	if not pan_enabled:
		panning_mouse = false
		panning_touch = false
		active_touch_id = -1
		pan_velocity = Vector2.ZERO


func _clamp_to_board() -> void:
	if board_size == Vector2.ZERO:
		return

	var viewport_size: Vector2 = get_viewport_rect().size * zoom
	var half: Vector2 = viewport_size * 0.5

	if board_size.x <= viewport_size.x:
		position.x = board_size.x * 0.5
	else:
		position.x = clamp(position.x, half.x, board_size.x - half.x)

	if board_size.y <= viewport_size.y:
		position.y = board_size.y * 0.5
	else:
		position.y = clamp(position.y, half.y, board_size.y - half.y)
