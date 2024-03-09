extends MeshInstance3D

var occupied = false
@onready var camera = get_node("/root/Game/Game Holder/Perspective/Camera3D")

#func _ready():
	#look_at_camera()
#
#func look_at_camera():
	#var sprite_position = Vector3(0,global_transform.origin.y,0)
	#var camera_position = Vector3(0,camera.global_transform.origin.y,0)
	#var direction_vector = (camera_position - sprite_position).normalized()
	#look_at(direction_vector, Vector3(0, 0, 0))
