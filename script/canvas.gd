extends Node2D


func _draw() -> void:
	for y in range(Globals.GRID_ROWS):
		for x in range(Globals.GRID_COLS):
			var rect := Rect2(
				x * Globals.CELL_SIZE,
				y * Globals.CELL_SIZE,
				Globals.CELL_SIZE,
				Globals.CELL_SIZE
			)
			var dark: bool = (x + y) % 2 == 0
			var color := Color(0.94, 0.90, 0.83, 0.25) if dark else Color(0.88, 0.84, 0.76, 0.25)
			draw_rect(rect, color, true)

	var border := Rect2(0, 0, Globals.GRID_COLS * Globals.CELL_SIZE, Globals.GRID_ROWS * Globals.CELL_SIZE)
	draw_rect(border, Color(0.25, 0.21, 0.16), false, 4.0)
