extends Sprite3D
class_name Gun

# On Ready 
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var delay_timer : Timer = get_node("Delay Timer")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")

# Local Variable
var camera : Camera
var modification : Dictionary
var heckler_owner : Heckler
var is_aiming : bool = true

func _ready():
	camera = get_viewport().get_camera_3d()
	audio_manager.play_music(int(Shared.E_SOUND_EFFECT.GUN_COCK), Shared.E_AUDIO_TYPE.SOUND_EFFECT)

func _process(delta):
	if (is_aiming):
		# Get input for movement direction
		var cloest_player_position : Vector3 = _find_closet_player()
		var gun_position : Vector3 = position
		var direction = cloest_player_position - gun_position

		position += direction * 2 * delta
		position.x = clamp(position.x, camera.screen_constraint["min_x"], camera.screen_constraint["max_x"])
		position.y = clamp(position.y, camera.screen_constraint["min_y"], camera.screen_constraint["max_y"])
		
		if(_is_player_in_crosshair() != null):
			is_aiming = false
			delay_timer.start(modification["delay"])

# Get player postion from camera panel
func _get_player_position(object : Node3D) -> Vector3:
	var ignore : Array[RID] = []
	for collision : StaticBody3D in get_tree().get_nodes_in_group("RayIgnore"):
		ignore.append(collision.get_rid())
	
	var query = PhysicsRayQueryParameters3D.create(camera.global_transform.origin, object.global_transform.origin)
	query.collide_with_areas = true
	query.exclude = ignore
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	if result and result.collider != null and result.collider.name == camera.camera_panel.name:
		var player_position : Vector3 = result.position - camera.camera_panel.global_transform.origin
		player_position.z = 0
		return player_position
	else:
		printerr("Camera Panel not detected")
		return Vector3(0,0,0)

# Find the closet player position
func _find_closet_player() -> Vector3 :
	var player_position : Array[Vector3]
	for key in game_manager.player_list.keys():
		player_position.append(_get_player_position(game_manager.player_list[key]["player_ref"]))
	return _closest_player(player_position)

# Find which player is closer to gun
func _closest_player(player_position: Array[Vector3]) -> Vector3:
	var closest_distance : float = player_position[0].distance_to(global_transform.origin)
	var closest_vector : Vector3 = player_position[0]

	for position in player_position:
		var distance = position.distance_to(global_transform.origin)
		if (distance < closest_distance):
			closest_distance = distance
			closest_vector = position
	return closest_vector

# Check player if target icon overlap player
func _is_player_in_crosshair() -> Comedian :
	var ray_length : float = 100.0
	var ray_direction : Vector3 = (global_transform.origin - camera.global_transform.origin).normalized()
	# Perform the raycast
	var ray_start : Vector3 = global_transform.origin
	var ray_end : Vector3 = ray_start + ray_direction * ray_length
	var param : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	var result : Dictionary = get_world_3d().direct_space_state.intersect_ray(param)
	
	# Check if the ray hits an object
	if result and result.collider != null and result.collider.name == "Comedian":
		return result.collider
	else:
		return null

# After a delay, fire gun
func _on_delay_timer_timeout():
	if(heckler_owner != null):
		var player : Comedian = _is_player_in_crosshair()
		visible = false
		heckler_owner.fire_gun()
		if (player != null):
			player.shot(modification["game_ender"])
		queue_free()
