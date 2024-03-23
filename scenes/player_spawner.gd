extends Node3D

@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var comedian : PackedScene = preload("res://prefab/player/comedian.tscn")

@export var spawn_dictionary : Array[NodePath]

func _ready():
	var is_singleplayer = game_manager.is_singleplayer
	print(is_singleplayer)
	if is_singleplayer:
		var instance = comedian.instantiate()
		instance.player_num = 1
		add_child(instance)
		instance.global_transform.origin = get_node(spawn_dictionary[0]).global_transform.origin
	else:
		var instance = comedian.instantiate()
		var instance2 = comedian.instantiate()
		instance.player_num = 1
		instance2.player_num =2
		add_child(instance)
		add_child(instance2)
		instance.global_transform.origin = get_node(spawn_dictionary[1]).global_transform.origin
		instance.global_transform.origin = get_node(spawn_dictionary[2]).global_transform.origin
	


