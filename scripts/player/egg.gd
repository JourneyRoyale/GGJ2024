extends Node3D
class_name Egg

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var emoji : Emoji = get_node("Emoji");

# Init variable from resources
var scale_duration : float
var target_scale : Vector3

# Variable
var time_elapsed = 0.0

func _init_resources() -> void :
	var level_resource : LevelResource = game_manager.level_resource

	scale_duration = level_resource.scale_duration
	target_scale = level_resource.target_scale

func _ready() -> void :
	_init_resources()
	emoji.set_random_emoji()

# Check if egg past boundary
func _process(delta : float) -> void :
	time_elapsed += delta
	# Calculate the scaling factor based on the elapsed time and duration
	var t = min(time_elapsed / scale_duration, 1.0)
	var scaling_factor = ease(t, 2.0)  # You can use different easing functions here
	# Calculate the new scale
	var new_scale = lerp(scale, target_scale, scaling_factor)
	# Set the new scale to the node
	scale = new_scale
	# Check if the scaling is complete
	if time_elapsed >= scale_duration:
		reset_egg()
	pass

func reset_egg() -> void :
	scale = Vector3(0.1,0.1,0.1)
	time_elapsed = 0.
	emoji.set_random_emoji()

func timing() -> float :
	return abs(scale.x - target_scale.x)
