extends Sprite2D

func _process(delta):
	var twoDNodePos = get_node("Target").global_position
	var threeDNodePos = get_node("Comedian").global_transform.origin

	# Get global position and orientation of the active camera
	var cameraPos = get_node("Camera3D").global_transform.origin
	var cameraDir = get_node("Camera3D").global_transform.basis.z

	# Calculate vectors from camera to nodes
	var vectorTo2D = (twoDNodePos - cameraPos).normalized()
	var vectorTo3D = (threeDNodePos - cameraPos).normalized()

	# Calculate dot products
	var dotProduct2D = vectorTo2D.dot(cameraDir)
	var dotProduct3D = vectorTo3D.dot(cameraDir)

	# Check if 2D node is in front of 3D node
	if dotProduct2D > dotProduct3D:
		print("2D node is in front of 3D node")
	else:
		print("3D node is in front of 2D node")
