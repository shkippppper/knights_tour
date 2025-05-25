extends Node2D

class_name Tile

var starting_position_y
var is_dropping = false
var is_rising = false
var animation_speed = 2
var can_knight_land = true
var current_tween = null
@export var tile_type:String

func _ready():
	starting_position_y = position.y 
	$Positioning.text = name.to_lower()
	$Positioning.visible = false
	
func drop():
	can_knight_land = false
	
	if !is_rising && !is_dropping:
		can_knight_land = false
		is_dropping = true
		
		if current_tween and current_tween.is_valid():
			current_tween.kill()
		
		current_tween = get_tree().create_tween()
		current_tween.tween_property(self, "position", Vector2(position.x, position.y + 2000), 2)
		current_tween.connect("finished", Callable(self, "_on_drop_completed"))

func _on_drop_completed():
	is_dropping = false
	
func rise():
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	is_dropping = false
	is_rising = true
	can_knight_land = true
	current_tween = get_tree().create_tween()
	current_tween.tween_property(self, "position", Vector2(position.x, starting_position_y), 0.2)
	current_tween.connect("finished", Callable(self, "_on_rise_completed"))

func _on_rise_completed():
	is_rising = false

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_pressed() && can_knight_land:
		get_parent().landed_on_tile(self)

func show_texture():
	$Guide.visible = true

func hide_texture():
	$Guide.visible = false
	
func update_positioning_visibility(show):
	$Positioning.visible = show
