extends MeshInstance3D
class_name Chair

# Onready
@onready var spawn_point_node : Node3D = get_node("Spawn Point")
@onready var sprite : Sprite3D = get_node("Sprite3D")

# Export
@export var can_sit : bool = true
@export var throw_type_allowed : Dictionary = {
	Shared.E_THROW_TYPE.SLING : 25,
	Shared.E_THROW_TYPE.UNDERHAND : 25,
	Shared.E_THROW_TYPE.OVERHAND : 25,
	Shared.E_THROW_TYPE.NONE : 25,
}

# Local variable
var occupied : bool = false
var current_entity : Node3D

func _ready():
	if (!can_sit):
		sprite.visible = false
	
	track_chair()

func track_chair() -> void:
	get_tree().call_group("AudienceManager", "track_chair", self)

func seat_entity(entity : Node3D, spawn_point : Node3D) -> void :
	entity.position = spawn_point.global_transform.origin
	entity.assigned_chair = self
	current_entity = entity
	occupied = true

func clear_chair() -> void :
	occupied = false
	current_entity = null

func get_chair_spawn_point() -> Node3D :
	return spawn_point_node

func get_chair_position() -> Vector3 :
	return spawn_point_node.global_transform.origin

func get_allowed_throw_type() -> Dictionary :
	var filtered_throw_type = {}
	for key in throw_type_allowed.keys():
		var value = throw_type_allowed[key]
		if value != 0:
			filtered_throw_type[key] = value
	
	return filtered_throw_type
