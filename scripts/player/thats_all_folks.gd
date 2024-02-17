extends Node3D

var in_time = 1
var out_time = 1
var current_time = 0
@onready var game_manager = get_node("/root/GameManager")
@export var player : Node3D

@export var start_x : float = -20.0
var target_x : float = 0.0

enum CANE_STATE { OFF, IN, OUT }
var current_state = CANE_STATE.OFF

# Called when the node enters the scene tree for the first time.
func _ready():
	current_state = CANE_STATE.OFF

func start():
	if current_state == CANE_STATE.OFF:
		current_time = 0
		position.x = start_x
		position.y = player.position.y
		position.z = player.position.z
		target_x = player.position.x
		current_state = CANE_STATE.IN

# Called every frame. 'delta' is the elapsed time since the previous framea
func _process(delta):
	if game_manager.isPlaying == true:
		if current_state == CANE_STATE.IN:
			if current_time < in_time:
				current_time += delta
				position.x = lerp(start_x, target_x, current_time / in_time)
			else:
				current_time = 0
				current_state = CANE_STATE.OUT
				player.thats_all_folks()
			position.y = player.position.y
			position.z = player.position.z
		elif current_state == CANE_STATE.OUT:
			if current_time < out_time:
				current_time += delta
				position.x = lerp(target_x, start_x, current_time / out_time)
			else:
				current_time = 0
				current_state = CANE_STATE.OFF
				game_manager.isPlaying = false
				get_tree().call_group("Curtains", "end_game")
			if player != null:
				player.position.x = position.x
			position.y = player.position.y
			position.z = player.position.z
		
		
