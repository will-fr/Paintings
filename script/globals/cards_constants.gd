extends RefCounted
class_name CardsConstants

const DEFAULT_CARD_SIZE := Vector2i(3, 3)
const DEFAULT_SCORING_RULE := "flat_10"
const DEFAULT_POINT_VALUE := 10

const CARDS: Array[Dictionary] = [
	{
		"id": "mona_lisa",
		"name": "Mona Lisa",
		"image_path": "res://gfx/paintings/mona_lisa.png",
		"size": Vector2i(3, 3),
		"scoring_rule": "flat_10",
		"scoring_text": "Gives 10 💛",
		"edge_top": 2,
		"edge_right": 1,
		"edge_bottom": 3,
		"edge_left": 1,
		"point_value": 10,
	},
	{
		"id": "starry_night",
		"name": "Starry Night",
		"image_path": "res://gfx/paintings/starry_night.png",
		"size": Vector2i(3, 3),
		"scoring_rule": "flat_10",
		"scoring_text": "Gives 10 💛",
		"edge_top": 4,
		"edge_right": 2,
		"edge_bottom": 2,
		"edge_left": 3,
		"point_value": 10,
	},
	{
		"id": "girl_with_a_pearl_earring",
		"name": "Girl with a Pearl Earring",
		"image_path": "res://gfx/paintings/girl_pierced_earring.png",
		"size": Vector2i(2, 3),
		"scoring_rule": "flat_10",
		"scoring_text": "Gives 10 💛",
		"edge_top": 1,
		"edge_right": 4,
		"edge_bottom": 2,
		"edge_left": 2,
		"point_value": 10,
	},
	{
		"id": "the_kiss",
		"name": "The Kiss",
		"image_path": "res://gfx/paintings/the_kiss.jpg",
		"size": Vector2i(3, 2),
		"scoring_rule": "flat_10",
		"scoring_text": "Gives 10 💛",
		"edge_top": 3,
		"edge_right": 3,
		"edge_bottom": 1,
		"edge_left": 4,
		"point_value": 10,
	},
	{
		"id": "the_scream",
		"name": "The Scream",
		"image_path": "res://gfx/paintings/the_scream.jpg",
		"size": Vector2i(3, 3),
		"scoring_rule": "flat_10",
		"scoring_text": "Gives 10 💛",
		"edge_top": 2,
		"edge_right": 2,
		"edge_bottom": 4,
		"edge_left": 1,
		"point_value": 10,
	},
	{
		"id": "guernica",
		"name": "Guernica",
		"image_path": "res://gfx/paintings/guernica.jpg",
		"size": Vector2i(4, 2),
		"scoring_rule": "flat_10",
		"scoring_text": "Gives 10 💛",
		"edge_top": 4,
		"edge_right": 4,
		"edge_bottom": 4,
		"edge_left": 4,
		"point_value": 10,
	},
]


static func get_starting_hand() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for i in range(min(5, CARDS.size())):
		result.append(CARDS[i].duplicate(true))
	return result


static func compute_score(card_data: Dictionary, _grid_pos: Vector2i, _adjacent_cards: Array = []) -> int:
	var scoring_rule: String = str(card_data.get("scoring_rule", DEFAULT_SCORING_RULE))
	var base_points: int = int(card_data.get("point_value", DEFAULT_POINT_VALUE))

	match scoring_rule:
		"flat_10":
			return base_points
		_:
			return base_points
