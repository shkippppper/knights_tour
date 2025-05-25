extends Node2D

var cursor_default = preload("res://Sprites/Misc/cursor_default2x.png")
var cursor_grab = preload("res://Sprites/Misc/cursor_grab2x.png")
var mouse_clicked = false
var is_zen_mode = false
var show_guide = false
var show_positioning = false
var show_annotation = false
var show_trail = false

#highscore
var high_score = 0
var config_file = ConfigFile.new()
var save_path = "user://high_score.cfg"

#tiles visual
var active_tiles = 3
var active_knight = 3

func _ready():
	load_high_score()
	update_high_score(high_score)
	update_map_button_visuals()
	update_knight_button_visuals()
	
	#trail
	var line_drawer = Node2D.new()
	line_drawer.name = "LineDrawer"
	line_drawer.z_index = 15
	line_drawer.set_script(preload("res://Scripts/LineDrawer.gd"))
	add_child(line_drawer)
	
func _process(delta):
	$Controls/Toggles/GuideCheckbox.button_pressed = show_guide
	$Controls/Toggles/AnnotationCheckbox.button_pressed = show_annotation
	$Controls/Toggles/PositioningCheckbox.button_pressed = show_positioning
	$Controls/Toggles/TrailCheckbox.button_pressed = show_trail
	$Annotation.visible = show_annotation
	update_history()
	
func _input(event):
	if event is InputEventMouseButton:
		mouse_clicked = event.pressed
		Input.set_custom_mouse_cursor(cursor_grab)
	
	if event is InputEventMouseMotion:
		if mouse_clicked:
			Input.set_custom_mouse_cursor(cursor_grab)
		else:
			Input.set_custom_mouse_cursor(cursor_default)

func _on_restart_button_down():
	$Board.restart_board()

func _on_undo_button_down():
	$Board.undo_move()

func _on_guide_button_button_down():
	show_guide = !show_guide

func _on_annotation_button_button_down():
	show_annotation = !show_annotation
	
func _on_positioning_button_button_down():
	show_positioning = !show_positioning

func _on_zen_button_button_down():
	is_zen_mode = !is_zen_mode
	
	$Controls/Toggles.visible = !is_zen_mode
	$Maps.visible = !is_zen_mode
	$Knights.visible = !is_zen_mode
	$Annotation.visible = !is_zen_mode
	$MoveHistory.visible = !is_zen_mode
	
	if is_zen_mode:
		show_guide = false
		show_positioning = false
		show_annotation = false
		show_trail = false
		

	var color = Color(0.87, 0.82, 0, 1) if is_zen_mode else Color(1, 1, 1, 1)
	var zen_button = $Controls/ZenButton

	zen_button.remove_theme_font_override("font_color")
	zen_button.remove_theme_font_override("font_focus_color")
	zen_button.add_theme_color_override("font_color", color)
	zen_button.add_theme_color_override("font_focus_color", color)

	
func _on_trail_button_button_down():
	show_trail = !show_trail
	
func update_score(score):
	$Scores/Score.text = str(score)
	if score > high_score:
		high_score = score
		save_high_score()
		update_high_score(high_score)

func update_high_score(score):
	$Scores/HighScore.text = str(score)

func save_high_score():
	config_file.set_value("game", "high_score", high_score)
	config_file.save(save_path)

func load_high_score():
	var error = config_file.load(save_path)
	if error == OK:
		high_score = config_file.get_value("game", "high_score", 0)
	else:
		high_score = 0

func change_map(map):
	active_tiles = map
	update_map_button_visuals()
	$Board.update_map_visuals(active_tiles)

func change_knight(knight):
	active_knight = knight
	update_knight_button_visuals()
	$Board.update_knight_visuals(active_knight)
	
func update_visual(show_array: Array[BaseButton], hide: BaseButton):
	hide.modulate = Color(1, 1, 1, 0.2)
	hide.disabled = true
	for showable in show_array:
		showable.modulate = Color(1, 1, 1, 1)
		showable.disabled = false
	
func update_map_button_visuals():
	var button_1 = $Maps/Map1Button
	var button_2 = $Maps/Map2Button
	var button_3 = $Maps/Map3Button
	
	if active_tiles == 1:
		update_visual([button_2, button_3], button_1)
	elif active_tiles == 2:
		update_visual([button_1, button_3], button_2)
	elif active_tiles == 3:
		update_visual([button_2, button_1], button_3)
		
func update_knight_button_visuals():
	var knight_1 = $Knights/Knight1
	var knight_2 = $Knights/Knight2
	var knight_3 = $Knights/Knight3
	var knight_4 = $Knights/Knight4
	var knight_5 = $Knights/Knight5
	var knight_6 = $Knights/Knight6
	var knight_7 = $Knights/Knight7
	var knight_8 = $Knights/Knight8
	var knight_9 = $Knights/Knight9
	var knight_10 = $Knights/Knight10
	var knight_11 = $Knights/Knight11
	var knight_12 = $Knights/Knight12

	if active_knight == 1:
		update_visual([knight_2, knight_3, knight_4, knight_5, knight_6, knight_7, knight_8, knight_9, knight_10, knight_11, knight_12], knight_1)
	elif active_knight == 2:
		update_visual([knight_1, knight_3, knight_4, knight_5, knight_6, knight_7, knight_8, knight_9, knight_10, knight_11, knight_12], knight_2)
	elif active_knight == 3:
		update_visual([knight_1, knight_2, knight_4, knight_5, knight_6, knight_7, knight_8, knight_9, knight_10, knight_11, knight_12], knight_3)
	elif active_knight == 4:
		update_visual([knight_1, knight_2, knight_3, knight_5, knight_6, knight_7, knight_8, knight_9, knight_10, knight_11, knight_12], knight_4)
	elif active_knight == 5:
		update_visual([knight_1, knight_2, knight_3, knight_4, knight_6, knight_7, knight_8, knight_9, knight_10, knight_11, knight_12], knight_5)
	elif active_knight == 6:
		update_visual([knight_1, knight_2, knight_3, knight_4, knight_5, knight_7, knight_8, knight_9, knight_10, knight_11, knight_12], knight_6)
	elif active_knight == 7:
		update_visual([knight_1, knight_2, knight_3, knight_4, knight_5, knight_6, knight_8, knight_9, knight_10, knight_11, knight_12], knight_7)
	elif active_knight == 8:
		update_visual([knight_1, knight_2, knight_3, knight_4, knight_5, knight_6, knight_7, knight_9, knight_10, knight_11, knight_12], knight_8)
	elif active_knight == 9:
		update_visual([knight_1, knight_2, knight_3, knight_4, knight_5, knight_6, knight_7, knight_8, knight_10, knight_11, knight_12], knight_9)
	elif active_knight == 10:
		update_visual([knight_1, knight_2, knight_3, knight_4, knight_5, knight_6, knight_7, knight_8, knight_9, knight_11, knight_12], knight_10)
	elif active_knight == 11:
		update_visual([knight_1, knight_2, knight_3, knight_4, knight_5, knight_6, knight_7, knight_8, knight_9, knight_10, knight_12], knight_11)
	elif active_knight == 12:
		update_visual([knight_1, knight_2, knight_3, knight_4, knight_5, knight_6, knight_7, knight_8, knight_9, knight_10, knight_11], knight_12)

func update_history():
	for i in range(1, 9): 
		var label_name = "History" + str(i)
		if $MoveHistory.has_node(label_name):
			$MoveHistory.get_node(label_name).text = ""

	for i in range($Board.move_history.size()):
		var label_index = int(i / 16) + 1
		var label_node_path = "History" + str(label_index)
		var label_node = $MoveHistory.get_node(label_node_path)
		var move_name = $Board.move_history[i].name

		var move_number = i + 1
		var spacing = " " if move_number < 10 else ""
		label_node.text += str(move_number) + spacing + ":K" + move_name.to_lower() + "\n"
