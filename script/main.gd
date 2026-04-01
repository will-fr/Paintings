extends Node2D

const CardsConstants = preload("res://script/globals/cards_constants.gd")

@onready var camera: Node = $MainCamera
@onready var score_label: Label = $HUD/ScoreLabel
@onready var canvas: Node2D = $Canvas
@onready var hand: CanvasLayer = $Hand

var score: int = 0
var drag_active := false
var drag_card_data: Dictionary = {}
var drag_card_texture: Texture2D
var drag_card_index := -1
var drag_card_size_cells := Vector2i(3, 3)
var drag_preview: Sprite2D
var last_pointer_screen_pos := Vector2.ZERO
var occupied_cells: Dictionary = {}

const DRAG_EDGE_PAN_MARGIN := 96.0
const DRAG_EDGE_PAN_SPEED := 1400.0
const DRAG_TINT_VALID := Color(1.0, 1.0, 1.0, 0.95)
const DRAG_TINT_INVALID := Color(1.0, 0.35, 0.35, 0.95)


func _ready() -> void:
	var board_size := Vector2(Globals.GRID_COLS * Globals.CELL_SIZE, Globals.GRID_ROWS * Globals.CELL_SIZE)
	if camera.has_method("configure_board_size"):
		camera.call("configure_board_size", board_size)
	if hand.has_signal("card_drag_started"):
		hand.connect("card_drag_started", _on_hand_card_drag_started)
	_update_score_label()


func _on_score_timer_timeout() -> void:
	score += 1
	_update_score_label()


func _update_score_label() -> void:
	score_label.text = "Score: %d" % score


func _input(event: InputEvent) -> void:
	if not drag_active:
		return

	if event is InputEventMouseMotion:
		last_pointer_screen_pos = event.position
		_update_drag_preview_position(last_pointer_screen_pos)
		get_viewport().set_input_as_handled()
		return

	if event is InputEventScreenDrag:
		last_pointer_screen_pos = event.position
		_update_drag_preview_position(last_pointer_screen_pos)
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		last_pointer_screen_pos = event.position
		_finish_drag(last_pointer_screen_pos)
		get_viewport().set_input_as_handled()
		return

	if event is InputEventScreenTouch and not event.pressed:
		last_pointer_screen_pos = event.position
		_finish_drag(last_pointer_screen_pos)
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if not drag_active:
		return

	_apply_drag_edge_pan(delta)


func _on_hand_card_drag_started(card_data: Dictionary, card_index: int, pointer_screen_pos: Vector2) -> void:
	if drag_active:
		return

	var texture_path: String = str(card_data.get("image_path", ""))
	var card_texture: Texture2D = load(texture_path)
	if card_texture == null:
		return

	var size_data: Variant = card_data.get("size", CardsConstants.DEFAULT_CARD_SIZE)
	var card_size_cells := CardsConstants.DEFAULT_CARD_SIZE
	if size_data is Vector2i:
		card_size_cells = size_data

	drag_active = true
	drag_card_data = card_data.duplicate(true)
	drag_card_texture = card_texture
	drag_card_index = card_index
	drag_card_size_cells = card_size_cells
	last_pointer_screen_pos = pointer_screen_pos

	hand.visible = false
	if camera.has_method("set_pan_enabled"):
		camera.call("set_pan_enabled", false)

	drag_preview = Sprite2D.new()
	drag_preview.texture = drag_card_texture
	drag_preview.centered = false
	drag_preview.z_index = 1000
	var target_size_px := Vector2(drag_card_size_cells.x, drag_card_size_cells.y) * Globals.CELL_SIZE
	drag_preview.scale = Vector2(
		target_size_px.x / maxf(1.0, float(drag_card_texture.get_width())),
		target_size_px.y / maxf(1.0, float(drag_card_texture.get_height()))
	)
	add_child(drag_preview)
	_update_drag_preview_position(last_pointer_screen_pos)


func _update_drag_preview_position(pointer_screen_pos: Vector2) -> void:
	if drag_preview == null:
		return

	var world_pos := _screen_to_world(pointer_screen_pos)
	var snapped := _snap_world_to_grid(world_pos)
	drag_preview.position = snapped

	if _can_place_card_at(snapped, drag_card_size_cells):
		drag_preview.modulate = DRAG_TINT_VALID
	else:
		drag_preview.modulate = DRAG_TINT_INVALID


func _finish_drag(pointer_screen_pos: Vector2) -> void:
	var world_pos := _screen_to_world(pointer_screen_pos)
	if _can_place_card_at(world_pos, drag_card_size_cells):
		_place_card(world_pos, drag_card_texture, drag_card_size_cells)
		var grid_pos := _world_to_cell(world_pos)
		score += CardsConstants.compute_score(drag_card_data, grid_pos)
		_update_score_label()
		if hand.has_method("remove_card"):
			hand.call("remove_card", drag_card_index)

	_end_drag()


func _end_drag() -> void:
	drag_active = false
	drag_card_data = {}
	drag_card_texture = null
	drag_card_index = -1
	drag_card_size_cells = CardsConstants.DEFAULT_CARD_SIZE

	if is_instance_valid(drag_preview):
		drag_preview.queue_free()
	drag_preview = null

	hand.visible = true
	if camera.has_method("set_pan_enabled"):
		camera.call("set_pan_enabled", true)


func _place_card(world_pos: Vector2, card_texture: Texture2D, card_size_cells: Vector2i) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = card_texture
	sprite.centered = false
	var snapped_pos := _snap_world_to_grid(world_pos)
	sprite.position = snapped_pos

	var target_size_px := Vector2(card_size_cells.x, card_size_cells.y) * Globals.CELL_SIZE
	sprite.scale = Vector2(
		target_size_px.x / maxf(1.0, float(card_texture.get_width())),
		target_size_px.y / maxf(1.0, float(card_texture.get_height()))
	)
	canvas.add_child(sprite)

	var top_left_cell := _world_to_cell(snapped_pos)
	_mark_cells_occupied(top_left_cell, card_size_cells)


func _snap_world_to_grid(world_pos: Vector2) -> Vector2:
	var cell_x := int(floor(world_pos.x / Globals.CELL_SIZE))
	var cell_y := int(floor(world_pos.y / Globals.CELL_SIZE))
	return Vector2(cell_x * Globals.CELL_SIZE, cell_y * Globals.CELL_SIZE)


func _can_place_card_at(world_pos: Vector2, card_size_cells: Vector2i) -> bool:
	var top_left_cell := Vector2i(
		int(floor(world_pos.x / Globals.CELL_SIZE)),
		int(floor(world_pos.y / Globals.CELL_SIZE))
	)

	if top_left_cell.x < 0 or top_left_cell.y < 0:
		return false

	if top_left_cell.x + card_size_cells.x > Globals.GRID_COLS:
		return false

	if top_left_cell.y + card_size_cells.y > Globals.GRID_ROWS:
		return false

	for y in range(card_size_cells.y):
		for x in range(card_size_cells.x):
			var cell := Vector2i(top_left_cell.x + x, top_left_cell.y + y)
			if occupied_cells.has(cell):
				return false

	return true


func _world_to_cell(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int(floor(world_pos.x / Globals.CELL_SIZE)),
		int(floor(world_pos.y / Globals.CELL_SIZE))
	)


func _mark_cells_occupied(top_left_cell: Vector2i, card_size_cells: Vector2i) -> void:
	for y in range(card_size_cells.y):
		for x in range(card_size_cells.x):
			var cell := Vector2i(top_left_cell.x + x, top_left_cell.y + y)
			occupied_cells[cell] = true


func _screen_to_world(screen_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * screen_pos


func _apply_drag_edge_pan(delta: float) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var pan_dir := Vector2.ZERO

	if last_pointer_screen_pos.x <= DRAG_EDGE_PAN_MARGIN:
		pan_dir.x = -1.0
	elif last_pointer_screen_pos.x >= viewport_size.x - DRAG_EDGE_PAN_MARGIN:
		pan_dir.x = 1.0

	if last_pointer_screen_pos.y <= DRAG_EDGE_PAN_MARGIN:
		pan_dir.y = -1.0
	elif last_pointer_screen_pos.y >= viewport_size.y - DRAG_EDGE_PAN_MARGIN:
		pan_dir.y = 1.0

	if pan_dir == Vector2.ZERO:
		return

	var pan_delta := pan_dir.normalized() * DRAG_EDGE_PAN_SPEED * delta
	if camera.has_method("pan_by"):
		camera.call("pan_by", pan_delta)

	_update_drag_preview_position(last_pointer_screen_pos)
