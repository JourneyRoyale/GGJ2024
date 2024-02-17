extends Node2D

var packed_egg = load("res://prefab/egg/egg.tscn")
@export var egg_delay = 1.0;
@export var egg_speed = 3.0
@onready var spawn_point = get_node("Spawn Point")
@onready var spawn_list = get_node("Spawn List")
@onready var timer = get_node("Timer")

func _on_timer_timeout():
	var instance = packed_egg.instantiate()
	instance.speed = egg_speed;
	spawn_list.add_child(instance)
	instance.animation.play("Egg Animation")
