extends Node2D

# On Ready
@onready var spawn_point = get_node("Spawn Point")
@onready var spawn_list = get_node("Spawn List")
@onready var timer = get_node("Timer")
@onready var egg_select = get_node("Egg Select")
@onready var packed_egg = load("res://prefab/egg/egg.tscn")

# Export
@export var is_dynamic_egg = false;
@export var flat_egg_delay = 1.0;
@export var dynamic_egg_delay = [];
@export var egg_speed = 3.0

# Variable
var selected_egg = null

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE and selected_egg != null:
			var select_distance = selected_egg.returnMiddleDistance(egg_select.get_node("Egg Middle").global_position)
			get_tree().call_group("AudienceManager", "check_for_match", selected_egg, select_distance)
			selected_egg.queue_free()

# On timer expire create egg
func _on_timer_timeout():
	var instance = packed_egg.instantiate()
	instance.speed = egg_speed;
	spawn_list.add_child(instance)
	instance.animation.play("Egg Animation")
	
	if(is_dynamic_egg):
		if(dynamic_egg_delay.size() > 0):
			var delay = dynamic_egg_delay.pop_front()
			timer.start(delay)
		else:
			timer.start()

func _on_area_2d_area_entered(area):
	selected_egg = area.get_parent()
	

func _on_area_2d_area_exited(area):
	selected_egg = null



