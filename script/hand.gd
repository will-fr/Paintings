extends CanvasLayer

const CARD_DISPLAY_HEIGHT := 256.0
const SCROLL_STEP := 320

@onready var hand_root: Control = $HandRoot
@onready var left_arrow: Button = $HandRoot/Panel/Margin/Row/LeftArrow
@onready var right_arrow: Button = $HandRoot/Panel/Margin/Row/RightArrow
@onready var cards_scroll: ScrollContainer = $HandRoot/Panel/Margin/Row/CardsScroll
@onready var cards_container: HBoxContainer = $HandRoot/Panel/Margin/Row/CardsScroll/Cards

@export var starting_cards: Array[Texture2D] = [
	preload("res://gfx/paintings/mona_lisa.png"),
	preload("res://gfx/paintings/starry_night.png"),
	preload("res://gfx/paintings/girl_pierced_earring.png"),
	preload("res://gfx/paintings/the_kiss.jpg"),
	preload("res://gfx/paintings/the_scream.jpg"),
]


func _ready() -> void:
	_populate_hand()
	hand_root.resized.connect(_update_arrow_state)
	cards_scroll.get_h_scroll_bar().value_changed.connect(_on_scroll_value_changed)
	_update_arrow_state()
	await get_tree().process_frame
	_update_arrow_state()


func _populate_hand() -> void:
	for child in cards_container.get_children():
		child.queue_free()

	for card_texture in starting_cards:
		var card := TextureRect.new()
		var resized_texture := _resize_texture_to_height(card_texture, int(CARD_DISPLAY_HEIGHT))
		card.texture = resized_texture
		card.custom_minimum_size = Vector2(resized_texture.get_width(), CARD_DISPLAY_HEIGHT)
		card.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		card.stretch_mode = TextureRect.STRETCH_KEEP
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cards_container.add_child(card)

	await get_tree().process_frame
	_update_arrow_state()


func _resize_texture_to_height(source_texture: Texture2D, target_height: int) -> Texture2D:
	var source_image := source_texture.get_image()
	if source_image == null or source_image.is_empty():
		return source_texture

	var aspect_ratio := float(source_image.get_width()) / float(source_image.get_height())
	var target_width := maxi(1, int(round(float(target_height) * aspect_ratio)))

	var resized_image := source_image.duplicate()
	resized_image.resize(target_width, target_height, Image.INTERPOLATE_LANCZOS)

	return ImageTexture.create_from_image(resized_image)


func _on_left_arrow_pressed() -> void:
	var max_scroll := int(round(cards_scroll.get_h_scroll_bar().max_value))
	if max_scroll <= 0:
		return

	cards_scroll.scroll_horizontal = clampi(cards_scroll.scroll_horizontal - SCROLL_STEP, 0, max_scroll)
	_update_arrow_state()


func _on_right_arrow_pressed() -> void:
	var max_scroll := int(round(cards_scroll.get_h_scroll_bar().max_value))
	if max_scroll <= 0:
		return

	cards_scroll.scroll_horizontal = clampi(cards_scroll.scroll_horizontal + SCROLL_STEP, 0, max_scroll)
	_update_arrow_state()


func _on_scroll_value_changed(_value: float) -> void:
	_update_arrow_state()


func _update_arrow_state() -> void:
	var max_scroll := int(round(cards_scroll.get_h_scroll_bar().max_value))
	var has_overflow := max_scroll > 0
	cards_scroll.scroll_horizontal = clampi(cards_scroll.scroll_horizontal, 0, max_scroll)

	left_arrow.visible = has_overflow
	right_arrow.visible = has_overflow

	if not has_overflow:
		cards_scroll.scroll_horizontal = 0
		return

	left_arrow.disabled = cards_scroll.scroll_horizontal <= 0
	right_arrow.disabled = cards_scroll.scroll_horizontal >= max_scroll
