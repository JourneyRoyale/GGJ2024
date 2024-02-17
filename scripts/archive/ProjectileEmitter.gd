extends Node3D

var packed_projectile = load("res://prefab/projectile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	emit_projectile_periodically()

func emit_projectile_periodically():
	await get_tree().create_timer(1).timeout
	var instance = packed_projectile.instantiate()
	add_child(instance)
	emit_projectile_periodically()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
