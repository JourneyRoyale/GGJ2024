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
	# If can't sit, then don't show chair
	if (!can_sit):
		sprite.visible = false

# Assign audience to chair 
func seat_audience(entity : Node3D, spawn_point : Node3D) -> void :
	entity.position = spawn_point.global_transform.origin
	entity.assigned_chair = self
	current_entity = entity
	occupied = true

# Clear chair for use
func clear_chair() -> void :
	occupied = false
	current_entity = null

# Return chair spawn point
func get_chair_spawn_point() -> Node3D :
	return spawn_point_node

# Return Chair Position
func get_chair_position() -> Vector3 :
	return spawn_point_node.global_transform.origin

# Return throw type allowed chance that is above 0
func get_allowed_throw_type() -> Dictionary :
	var filtered_throw_type : Dictionary = {}
	for key in throw_type_allowed.keys():
		var value = throw_type_allowed[key]
		if value != 0:
			filtered_throw_type[key] = value
	
	return filtered_throw_type
