extends Node2D

signal knight_hovered

const black_tile_preload := preload("res://Scenes/black_chess_tile.tscn")
const white_tile_preload := preload("res://Scenes/white_chess_tile.tscn")
const knight_preload := preload("res://Scenes/knight.tscn")
const tile_names := ["A", "B", "C", "D", "E", "F", "G", "H"]
const board_size_x := 8
const board_size_y := 8

var screen_size
var tile_size := 16
var tile_scale := 6
var knight_on_tile
var knight_instance
var knight_scale
var move_history := []
var show_trail = false

const STARTING_POSITION_X := 0

func _ready():
	screen_size = get_viewport_rect().size	
	tile_size = tile_size * tile_scale / 2 #this is to match the scale on tile scenes scale
	
	create_board()
	drop_knight()

func _process(delta):
	update_possible_tile_texture()
	update_piece_positioning()
	get_parent().update_score(move_history.size())
	show_trail = get_parent().show_trail

func create_board():
	var position_x = STARTING_POSITION_X
	var position_y = 0
	var tile_count = 0
	var position_z = 1
	for i in board_size_x:
		for j in board_size_y:
			var tile
			if tile_count % 2 == 0:
				tile = white_tile_preload.instantiate()
			else:
				tile = black_tile_preload.instantiate()
				
			tile.position.x = position_x + (tile_size * j)
			tile.position.y = position_y
			tile.z_index = position_z
			tile.name = tile_names[j] + str(8 - i)
			add_child(tile)
			position_x += tile_size
			tile_count += 1
		tile_count += 1 #to balance the W-B-W on board on second line
		position_x = STARTING_POSITION_X
		position_y += tile_size * 2

func drop_knight():
	var knight = knight_preload.instantiate()
	knight_on_tile = "A1" 
	var first_tile
	for child in get_children():
		if child.name == knight_on_tile:
			first_tile = child
			move_history.append(first_tile)
	knight.position.x = first_tile.position.x
	knight.position.y = first_tile.position.y - 10
	add_child(knight)
	knight_scale = knight.scale
	knight_instance = knight

func landed_on_tile(tile):
	if can_knight_land(tile):
		tile.can_knight_land = false
		move_knight(tile)
		await get_tree().create_timer(0.3).timeout 
		for child in get_children():
			if child.name == knight_on_tile:
				child.drop()
		knight_on_tile = tile.name
		move_history.append(tile)

func move_knight(tile):
	rotate_if_needed(tile)
	knight_instance.jump_knight()
	var tween = get_tree().create_tween()
	tween.tween_property(knight_instance, "position", Vector2(tile.position.x, tile.position.y - 10) , 0.4)
	
func rotate_if_needed(new_tile):
	if knight_instance.position.x < new_tile.position.x && knight_instance.facing_left:
		knight_instance.rotate_knight()
	elif knight_instance.position.x > new_tile.position.x && !knight_instance.facing_left:
		knight_instance.rotate_knight()

func can_knight_land(new_tile):
	var can_land = false
	var new_tile_name = String(knight_on_tile)
	var tile_letter_index = tile_names.find(new_tile_name.left(1))
	var tile_number = int(new_tile_name.right(1))
	var possible_tile_array = check_possible_tiles(tile_letter_index, tile_number)
	var can_land_on_tiles = []

	for tile in possible_tile_array:
		for child in get_children():
			if tile == child.name && child.can_knight_land:
				can_land_on_tiles.append(tile)
	
	for tile in can_land_on_tiles:
		if String(new_tile.name) == tile:
			can_land = true
	
	return can_land

func check_possible_tiles(tile_letter_index, tile_number):
	var RRT # RIGHT RIGHT TOP     -> -> ^
	var RRB # RIGHT RIGHT BOTTOM  -> -> v
	var TTR # TOP TOP RIGHT       ^  ^ ->
	var TTL # TOP TOP LEFT        ^  ^ <-
	var LLT # LEFT LEFT TOP       <- <- ^
	var LLB # LEFT LEFT BOTTOM    <- <- v
	var BBL # BOTTOM BOTTOM LEFT  v  v <-
	var BBR # BOTTOM BOTTOM RIGHT v  v ->
	
	var possible_tiles = []
	
	if tile_letter_index + 2 <= 7 && tile_number + 1 <= 8:
		RRT = str(str(tile_names[tile_letter_index + 2]), str(tile_number + 1))
		possible_tiles.append(RRT)
		
	if tile_letter_index + 2 <= 7 && tile_number - 1 >= 1:
		RRB = str(str(tile_names[tile_letter_index + 2]), str(tile_number - 1))
		possible_tiles.append(RRB)
		
	if tile_letter_index + 1 <= 7 && tile_number + 2 <= 8:
		TTR = str(str(tile_names[tile_letter_index + 1]), str(tile_number + 2))
		possible_tiles.append(TTR)
		
	if tile_letter_index - 1 >= 0 && tile_number + 2 <= 8:
		TTL = str(str(tile_names[tile_letter_index - 1]), str(tile_number + 2))
		possible_tiles.append(TTL)
		
	if tile_letter_index - 2 >= 0 && tile_number + 1 <= 8:
		LLT = str(str(tile_names[tile_letter_index - 2]), str(tile_number + 1))	
		possible_tiles.append(LLT)
		
	if tile_letter_index - 2 >= 0 && tile_number - 1 >= 1:
		LLB = str(str(tile_names[tile_letter_index - 2]), str(tile_number - 1))	
		possible_tiles.append(LLB)
		
	if tile_letter_index - 1 >= 0 && tile_number - 2 >= 1:
		BBL = str(str(tile_names[tile_letter_index - 1]), str(tile_number - 2))	
		possible_tiles.append(BBL)
		
	if tile_letter_index + 1 <= 7 && tile_number - 2 >= 1:
		BBR = str(str(tile_names[tile_letter_index + 1]), str(tile_number - 2))		
		possible_tiles.append(BBR)
		
	return possible_tiles

func restart_board():
	if (knight_on_tile == "A1"):
		return
	move_history.clear()
	var shuffled_children = get_children()
	var first_tile
	shuffled_children.shuffle()
	for child in shuffled_children:
		await get_tree().create_timer(0.01).timeout
		if child.name != "Knight":
			if child.name == "A1":
				first_tile = child
				move_history.append(first_tile)
			child.rise()
	await get_tree().create_timer(0.6).timeout
	move_knight(first_tile)
	knight_on_tile = "A1" 

func undo_move():
	if move_history.size() > 1:
		move_history[move_history.size() - 1].can_knight_land = true
		move_history.pop_back()
		var last_tile = move_history[move_history.size() - 1] 
		last_tile.rise()
		await get_tree().create_timer(0.5).timeout
		move_knight(last_tile)
		knight_on_tile = last_tile.name

func update_possible_tile_texture():
	if !get_parent().show_guide:
		for child in get_children():
			if child.name == "Knight":
				return
			child.hide_texture()
	else:
		var new_tile_name = String(knight_on_tile)
		var tile_letter_index = tile_names.find(new_tile_name.left(1))
		var tile_number = int(new_tile_name.right(1))
		var possible_tile_array = check_possible_tiles(tile_letter_index, tile_number)
		var actual_possible_children = []
		for child in get_children():
			if child.name == "Knight":
				return
			for tile in possible_tile_array:
				if tile == child.name && child.can_knight_land && possible_tile_array.has(tile):
					actual_possible_children.append(child)
					child.show_texture()
				elif !actual_possible_children.has(child):
					child.hide_texture()

func update_map_visuals(active_map):
	var map_index = clamp(active_map, 1, 3)

	var texture_white = load("res://Sprites/Board/board%d-white.png" % map_index)
	var texture_black = load("res://Sprites/Board/board%d-black.png" % map_index)

	for child in get_children():
		if child.name == "Knight":
			return
		for child_node in child.get_children():
			if child_node is Sprite2D and child_node.name == "Sprite2D":
				child_node.texture = texture_black if child.tile_type == "Black" else texture_white


func update_knight_visuals(active_knight):
	var knight_texture = load("res://Sprites/Pieces/knight_%d.png" % active_knight)

	for child in get_children():
		if child.name == "Knight":
			child.jump_knight_with_rotation()
			for child_node in child.get_children():
				if child_node is Sprite2D and child_node.name == "ActiveKnight":
					child_node.texture = knight_texture

func update_piece_positioning():
	for child in get_children():
		if child.name == "Knight":
			return
		for child_node in child.get_children():
			if child_node is Label and child_node.name == "Positioning":
				child.update_positioning_visibility(get_parent().show_positioning)
