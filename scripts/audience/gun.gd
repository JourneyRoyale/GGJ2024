extends Sprite3D
class_name Gun

# On Ready 
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var delay_timer : Timer = get_node("Delay Timer")

# Local Variable
var camera : Camera
var modification : Dictionary
var heckler_owner : Heckler
var is_aiming : bool = true

func _ready():
	camera = get_viewport().get_camera_3d()
	print(game_manager.player_list)

func _process(delta):
	
	if (is_aiming):
		# Get input for movement direction
		var player = _find_closet_player()
		var guns = position
		var direction = player - guns

		position += direction * 2 * delta
		position.x = clamp(position.x, camera.screen_constraint["min_x"], camera.screen_constraint["max_x"])
		position.y = clamp(position.y, camera.screen_constraint["min_y"], camera.screen_constraint["max_y"])
		
		if(_is_player_in_crosshair() != null):
			is_aiming = false
			delay_timer.start(modification["delay"])

func _get_player_position(object : Node3D) -> Vector3:
	var query = PhysicsRayQueryParameters3D.create(camera.global_transform.origin, object.global_transform.origin)
	query.collide_with_areas = true
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result and result.collider != null and result.collider.name == camera.camera_panel.name:
		var player_position : Vector3 = result.position - camera.camera_panel.global_transform.origin
		player_position.z = 0
		return player_position
	else:
		print("this is an error")
		return Vector3(0,0,0)

func _find_closet_player() -> Vector3 :
	var player_position : Array[Vector3]
	for player in game_manager.player_list:
		player_position.append(_get_player_position(player))
	return _closest_player(player_position)

func _closest_player(player_position: Array[Vector3]) -> Vector3:
	var closest_distance
	var closest_vector

	for position in player_position:
		var distance = position.distance_to(global_transform.origin)
		if (closest_vector == null):
			closest_vector = position
		elif (distance < closest_distance):
			closest_distance = distance
			closest_vector = position
	return closest_vector

func _is_player_in_crosshair() -> Comedian :
	var ray_length = 100.0
	var ray_direction = (global_transform.origin - camera.global_transform.origin).normalized()
	# Perform the raycast
	var ray_start = global_transform.origin
	var ray_end = ray_start + ray_direction * ray_length
	var param = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	var result = get_world_3d().direct_space_state.intersect_ray(param)
	
	# Check if the ray hits an object
	if result and result.collider != null and result.collider.name == "Comedian":
		return result.collider
	else:
		return null


func _on_delay_timer_timeout():
	var player : Comedian = _is_player_in_crosshair()
	visible = false
	heckler_owner.fire_gun()
	if (player != null):
		player.shot()
	queue_free()
