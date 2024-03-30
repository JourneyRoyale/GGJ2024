extends Area3D
class_name TargetMap

@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var floor_collision : CollisionShape3D = get_node("CollisionShape3D")

# Local Variable
var target_constraint : Dictionary

func _ready() -> void :
	_generate_constraint()

# Generate target map constraint
func _generate_constraint() -> void :
	var collider_size = floor_collision.shape.size
	var min_position = global_transform.origin - collider_size / 2
	var max_position = global_transform.origin + collider_size / 2
	
	target_constraint = {
		"min_x": min_position.x,
		"max_x": max_position.x,
		"min_z": min_position.z,
		"max_z": max_position.z,
	}

# Get random target position from target map constraint
func get_random_target_position(throw_type : Shared.E_THROW_TYPE, aggressive : float) -> Vector3 :	
	var random_position = Vector3.ZERO
	var x : float = randf_range(target_constraint["min_x"],target_constraint["max_x"])
	var z : float = randf_range(target_constraint["min_z"],target_constraint["max_z"])
	random_position = Vector3(x, 0 ,z)
	var player_position : Vector3 = _find_closet_player_position_from_target(random_position)
	var midpoint : Vector3 = (random_position + player_position) / 2.0
	
	 # Move the random position closer to the player by a certain factor
	var closer_position : Variant = lerp(random_position, player_position, aggressive)
	
	if(throw_type == Shared.E_THROW_TYPE.SLING):
		closer_position.y = 1
	else:
		closer_position.y = 1
	
	return closer_position

# Find cloest player from target position
func _find_closet_player_position_from_target(target_position : Vector3) -> Vector3 :
	var player_position : Array[Vector3]
	for key in game_manager.player_list.keys():
		player_position.append(game_manager.player_list[key]["player_ref"].global_transform.origin)
	
	var closest_distance : float = 0
	var closest_vector : Vector3

	for position in player_position:
		var distance = position.distance_to(target_position)
		if (closest_vector == null):
			closest_vector = position
		elif (distance < closest_distance):
			closest_distance = distance
			closest_vector = position
	return closest_vector
