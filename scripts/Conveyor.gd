extends Control

var packed_egg = load("res://prefab/egg.tscn")
@export var egg_delay = 1.0;
@export var egg_speed = 3.0

func _on_timer_timeout():
	var instance = packed_egg.instantiate()
	instance.speed = egg_speed;
	add_child(instance)
