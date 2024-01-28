extends Control

var packed_egg = load("res://prefab/Egg.tscn")
@export var egg_delay = 1.0;
@export var egg_speed = 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	add_joke()

func add_joke():
	await get_tree().create_timer(egg_delay).timeout
	var instance = packed_egg.instantiate()
	instance.speed = egg_speed;
	add_child(instance)
	add_joke()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
