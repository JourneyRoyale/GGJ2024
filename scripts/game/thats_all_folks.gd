extends Node3D

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")

# Constant
var in_time = 1
var out_time = 1
var current_time = 0

# Export
@export var player : Node3D
@export var start_x : float = -20.0

# Enum
enum CANE_STATE { OFF, IN, OUT }

# Variable
var current_state = CANE_STATE.OFF
var target_x : float = 0.0

# Move Cane until it hits player
func _process(delta : float) -> void :
	if game_manager.is_playing == true:
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
				game_manager.is_playing = false
				get_tree().call_group("Curtains", "end_game")
			if player != null:
				player.position.x = position.x
			position.y = player.position.y
			position.z = player.position.z

# Set cane starting
func start() -> void :
	if current_state == CANE_STATE.OFF:
		current_time = 0
		position.x = start_x
		position.y = player.position.y
		position.z = player.position.z
		target_x = player.position.x
		current_state = CANE_STATE.IN

