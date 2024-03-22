extends Camera3D
class_name Camera

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var camera_panel : Node3D = get_node("Camera Panel")
@onready var packed_target : PackedScene = load("res://prefab/audience/target.tscn")
@onready var spawner : Node3D = get_node("Spawner")
# Local Variable
var screen_constraint : Dictionary


func _ready():
	calculate_view_bounds()

func look_at_camera(node : Node3D) -> void :
	return node.look_at(global_transform.origin, Vector3.UP)

func calculate_view_bounds():
	var viewport = get_viewport().size
	var aspect_ratio = float(viewport.x) / float(viewport.y)
	var distance_from_camera = 4
	
	# Get the camera's field of view and convert it to radian
	var fov_degrees = get_fov()
	var fov_radians = deg_to_rad(fov_degrees)
	
	# Calculate the height of the frustum at the specified distance from the camera
	var frustum_height = 2.0 * distance_from_camera * tan(fov_radians / 2.0)

	# Calculate the width of the frustum based on the aspect ratio
	var frustum_width = frustum_height * aspect_ratio
	
	# Calculate the half-width and half-height of the frustum
	var half_width = frustum_width / 2.0
	var half_height = frustum_height / 2.0
	
	# Calculate the bounds of the camera's view
	screen_constraint = {
		"min_x": -half_width,
		"max_x": half_width,
		"min_y": -half_height,
		"max_y": half_height,
	}
#
#func _process(delta):
	#var input_dir = Input.get_vector("left", "right", "up", "down")
	#var direction = (transform.basis * Vector3(input_dir.x, input_dir.y, 0)).normalized()
	#direction.z = 0
#
	#if (direction != Vector3(0,0,0)):
		#target.position += direction * 1 * delta
#
		### Clamp object's position within constraints
		##target.position.x = clamp(target.position.x, screen_constraint["min_x"], screen_constraint["max_x"])
		##target.position.y = clamp(target.position.y, screen_constraint["min_y"], screen_constraint["max_y"])
		#
		#var ray_length = 100.0
		#var ray_direction = (target.global_transform.origin - global_transform.origin).normalized()
		## Perform the raycast
		#var ray_start = global_transform.origin
		#var ray_end = ray_start + ray_direction * ray_length
		#var param = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
		#var result = get_world_3d().direct_space_state.intersect_ray(param)
		#
		## Check if the ray hits an object
		#if result and result.collider != null and result.collider.name == "Comedian":
			#print("Correct Position:", result.collider.name, target.position)

func _get_random_position() -> Vector3 :
	var random_x = game_manager.rng.randi_range(screen_constraint["min_x"], screen_constraint["max_x"])
	var random_y = game_manager.rng.randi_range(screen_constraint["min_y"], screen_constraint["max_y"])
	return Vector3(random_x, random_y, 0)

func spawn_target(modification : Dictionary, heckler : Heckler) -> void :
	var instance : Gun = packed_target.instantiate()
	spawner.add_child(instance)
	
	instance.heckler_owner = heckler
	instance.modification = modification
	instance.position = _get_random_position()
