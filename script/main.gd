extends Node2D

@onready var camera: Node = $MainCamera
@onready var score_label: Label = $HUD/ScoreLabel

var score: int = 0


func _ready() -> void:
	var board_size := Vector2(Globals.GRID_COLS * Globals.CELL_SIZE, Globals.GRID_ROWS * Globals.CELL_SIZE)
	if camera.has_method("configure_board_size"):
		camera.call("configure_board_size", board_size)
	_update_score_label()


func _on_score_timer_timeout() -> void:
	score += 1
	_update_score_label()


func _update_score_label() -> void:
	score_label.text = "Score: %d" % score
