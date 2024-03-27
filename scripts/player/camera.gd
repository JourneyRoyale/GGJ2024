extends Camera3D
class_name Camera

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var camera_panel : Node3D = get_node("Camera Panel")
@onready var packed_target : PackedScene = load("res://prefab/game/gun.tscn")
@onready var spawner : Node3D = get_node("Spawner")

# Local Variable
var screen_constraint : Dictionary

func _ready():
	_calculate_view_bounds()

# Caculate screen contstraint
func _calculate_view_bounds():
	# Current camera setup
	var viewport : Vector2i = get_viewport().size
	var aspect_ratio = float(viewport.x) / float(viewport.y)
	var distance_from_camera : float = 4.0
	
	# Get the camera's field of view and convert it to radian
	var fov_degrees : float = get_fov()
	var fov_radians : float = deg_to_rad(fov_degrees)
	
	# Calculate the height of the frustum at the specified distance from the camera
	var frustum_height : float = 2.0 * distance_from_camera * tan(fov_radians / 2.0)

	# Calculate the width of the frustum based on the aspect ratio
	var frustum_width : float = frustum_height * aspect_ratio
	
	# Calculate the half-width and half-height of the frustum
	var half_width : float = frustum_width / 2.0
	var half_height : float = frustum_height / 2.0
	
	# Set the bounds of the camera's view
	screen_constraint = {
		"min_x": -half_width,
		"max_x": half_width,
		"min_y": -half_height,
		"max_y": half_height,
	}

# Get random position constraint to the screen
func _get_random_position() -> Vector3 :
	var random_x = game_manager.rng.randi_range(screen_constraint["min_x"], screen_constraint["max_x"])
	var random_y = game_manager.rng.randi_range(screen_constraint["min_y"], screen_constraint["max_y"])
	return Vector3(random_x, random_y, 0)

# Spawn Gun Target Icon
func spawn_target(modification : Dictionary, heckler : Heckler) -> void :
	var instance : Gun = packed_target.instantiate()
	spawner.add_child(instance)
	
	instance.heckler_owner = heckler
	instance.modification = modification
	instance.position = _get_random_position()
