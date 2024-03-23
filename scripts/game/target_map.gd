extends Area3D
class_name TargetMap

@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var floor_collision : CollisionShape3D = get_node("CollisionShape3D")

# Init variable from resources
var target_vertical : float = 1.3

# Local Variable
var target_constraint : Dictionary

func _ready() -> void :
	_generate_constraint()

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

func get_random_target_position(throw_type : Shared.E_THROW_TYPE, aggressive : float) -> Vector3 :	
	var random_position = Vector3.ZERO
	var x = randf_range(target_constraint["min_x"],target_constraint["max_x"])
	var z = randf_range(target_constraint["min_z"],target_constraint["max_z"])
	if(throw_type == Shared.E_THROW_TYPE.SLING):
		random_position = Vector3(x, 1.3 ,z)
	else:
		random_position = Vector3(x, 0.5 ,z)
	
	var player_position = _find_closet_player(random_position)
	var midpoint = (random_position + player_position) / 2.0
	
	 # Move the random position closer to the player by a certain factor
	var closer_position = lerp(random_position, player_position, aggressive)
	
	return closer_position

func _find_closet_player(target_position : Vector3) -> Vector3 :
	var player_position : Array[Vector3]
	for key in game_manager.player_list.keys():
		player_position.append(game_manager.player_list[key]["player_ref"].global_transform.origin)
	
	var closest_distance
	var closest_vector

	for position in player_position:
		var distance = position.distance_to(target_position)
		if (closest_vector == null):
			closest_vector = position
		elif (distance < closest_distance):
			closest_distance = distance
			closest_vector = position
	return closest_vector
