extends Node2D

var facing_left = true
var starting_pos_y = 0.6

func rotate_knight():
	facing_left = !facing_left
	var x_scale 
	if facing_left:
		x_scale = 1
	else:
		x_scale = -1
	var tween = get_tree().create_tween()
	tween.tween_property($ActiveKnight, "scale", Vector2(x_scale, 1) , 0.2)

func jump_knight():
	var tween = get_tree().create_tween()
	tween.tween_property($ActiveKnight, "position", Vector2(0.2, -30) , 0.2)
	tween.tween_property($ActiveKnight, "position", Vector2(0.2, -0.6) , 0.2)

func jump_knight_with_rotation():
	jump_knight()
	var tween = get_tree().create_tween()
	tween.tween_property($ActiveKnight, "rotation_degrees", 360, 0.2)
	$ActiveKnight.rotation_degrees = 0
