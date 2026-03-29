extends Node2D

const GC = preload("res://script/globals/game_constants.gd")

@onready var camera: Node = $MainCamera


func _ready() -> void:
	if camera.has_method("configure_board_size"):
		camera.call("configure_board_size", GC.board_pixel_size())
