extends Node3D
class_name Joke

# Egg look at camera
func _process(delta : float) -> void :
	look_at(get_viewport().get_camera_3d().global_transform.origin, Vector3.UP)
