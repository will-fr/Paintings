extends Node

const GRID_COLS := 40
const GRID_ROWS := 40
const CELL_SIZE := 128


static func board_pixel_size() -> Vector2:
	return Vector2(GRID_COLS * CELL_SIZE, GRID_ROWS * CELL_SIZE)
