extends Node3D

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")

# Constant
var in_time = 1
var out_time = 1
var current_time = 0

# Export
@export var start_x : float = -20.0

# Enum
enum CANE_STATE { OFF, IN, OUT }

# Variable
var current_state = CANE_STATE.OFF
var target_x : float = 0.0
var target_player : Node3D

# Move Cane until it hits player
func _process(delta : float) -> void :
	if game_manager.is_playing == true and target_player != null:
		if current_state == CANE_STATE.IN:
			if current_time < in_time:
				current_time += delta
				position.x = lerp(start_x, target_x, current_time / in_time)
			else:
				current_time = 0
				current_state = CANE_STATE.OUT
				target_player.thats_all_folks()
			position.y = target_player.position.y
			position.z = target_player.position.z
		elif current_state == CANE_STATE.OUT:
			if current_time < out_time:
				current_time += delta
				position.x = lerp(target_x, start_x, current_time / out_time)
			else:
				current_time = 0
				current_state = CANE_STATE.OFF
				game_manager.is_playing = false
				get_tree().call_group("Curtains", "end_game")
			if target_player != null:
				target_player.position.x = position.x
			position.y = target_player.position.y
			position.z = target_player.position.z

# Set cane starting
func start(player : Comedian) -> void :
	if current_state == CANE_STATE.OFF:
		target_player = player
		current_time = 0
		position.x = start_x
		position.y = player.position.y
		position.z = player.position.z
		target_x = player.position.x
		current_state = CANE_STATE.IN

