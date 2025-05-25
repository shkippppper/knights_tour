extends Node2D

var board_reference
var line_width = 5
var line_color = Color(0.92, 0.4, 0, 0.8)

func _ready():
	board_reference = get_parent().get_node("Board")

func _draw():
	if not board_reference or not board_reference.show_trail or board_reference.move_history.size() < 2:
		return
	
	for i in range(board_reference.move_history.size() - 1):
		var current_tile = board_reference.move_history[i]
		var next_tile = board_reference.move_history[i + 1]
		
		if current_tile and next_tile:
			var board_offset = board_reference.position
			var start_pos = Vector2(current_tile.position.x + board_offset.x, current_tile.starting_position_y + board_offset.y)
			var end_pos = Vector2(next_tile.position.x + board_offset.x, next_tile.starting_position_y + board_offset.y)
			draw_line(start_pos, end_pos, line_color, line_width, true)

func _process(delta):
	queue_redraw()
