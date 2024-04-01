extends StaticBody3D
class_name Trajectory

var origin_projectile : Projectile

func set_color(color : Color):
	var meshinstance : MeshInstance3D = get_node("MeshInstance3D")
	var material : Material = StandardMaterial3D.new()
	material.albedo_color = color
	meshinstance.set_surface_override_material(0,material)
