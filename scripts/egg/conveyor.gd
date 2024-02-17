extends Node2D

# On Ready
@onready var packed_egg = load("res://prefab/egg/egg.tscn")
@onready var spawn_point = get_node("Spawn Point")
@onready var spawn_list = get_node("Spawn List")
@onready var timer = get_node("Timer")

# Export
@export var egg_delay = 1.0;
@export var egg_speed = 3.0

func _on_timer_timeout():
	var instance = packed_egg.instantiate()
	instance.speed = egg_speed;
	spawn_list.add_child(instance)
