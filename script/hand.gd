extends CanvasLayer

const CARD_DISPLAY_HEIGHT := 256.0

@onready var cards_container: HBoxContainer = $HandRoot/Panel/Margin/Cards

@export var starting_cards: Array[Texture2D] = [
	preload("res://gfx/paintings/mona_lisa.png"),
	preload("res://gfx/paintings/starry_night.png"),
	preload("res://gfx/paintings/girl_pierced_earring.png"),
	preload("res://gfx/paintings/the_kiss.jpg"),
	preload("res://gfx/paintings/the_scream.jpg"),
]


func _ready() -> void:
	_populate_hand()


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


func _resize_texture_to_height(source_texture: Texture2D, target_height: int) -> Texture2D:
	var source_image := source_texture.get_image()
	if source_image == null or source_image.is_empty():
		return source_texture

	var aspect_ratio := float(source_image.get_width()) / float(source_image.get_height())
	var target_width := maxi(1, int(round(float(target_height) * aspect_ratio)))

	var resized_image := source_image.duplicate()
	resized_image.resize(target_width, target_height, Image.INTERPOLATE_LANCZOS)

	return ImageTexture.create_from_image(resized_image)
