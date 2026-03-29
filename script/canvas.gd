extends Node2D

const GC = preload("res://script/globals/game_constants.gd")


func _draw() -> void:
	for y in range(GC.GRID_ROWS):
		for x in range(GC.GRID_COLS):
			var rect := Rect2(
				x * GC.CELL_SIZE,
				y * GC.CELL_SIZE,
				GC.CELL_SIZE,
				GC.CELL_SIZE
			)
			var dark: bool = (x + y) % 2 == 0
			var color := Color(0.94, 0.90, 0.83, 0.25) if dark else Color(0.88, 0.84, 0.76, 0.25)
			draw_rect(rect, color, true)

	var border := Rect2(0, 0, GC.GRID_COLS * GC.CELL_SIZE, GC.GRID_ROWS * GC.CELL_SIZE)
	draw_rect(border, Color(0.25, 0.21, 0.16), false, 4.0)
