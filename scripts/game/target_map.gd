extends Area3D
class_name TargetMap

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

func get_random_target_position(throw_type : Shared.E_ThrowType) -> Vector3 :	
	var x = randf_range(target_constraint["min_x"],target_constraint["max_x"])
	var z = randf_range(target_constraint["min_z"], target_constraint["max_z"])
	if(throw_type == Shared.E_ThrowType.SLING):
		return Vector3(x, 1.3 ,z)
	else:
		return Vector3(x, 0.5 ,z)
