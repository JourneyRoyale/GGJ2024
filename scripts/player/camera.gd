extends Camera3D
class_name Camera

func look_at_camera(node : Node3D) -> void :
	return node.look_at(global_transform.origin, Vector3.UP)
