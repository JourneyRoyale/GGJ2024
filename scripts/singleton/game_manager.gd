extends Node
class_name GameManager

# On Ready
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var ui_screen : Control = get_node("/root/Game/Ui Screen")
@onready var game_holder : Node3D = get_node("/root/Game/Game Holder")
@onready var shock_timer : Timer = get_node("Shock Timer")

# Export
@export var level_resource_dictionary : Dictionary = {}

# Init variable from resources
var multiplier_increase_frequency : int = 3; #How many jokes in the combo before multiplier goes up
var error_amount : int = 10
var match_amount : int = 10
var annoyed_amount : int = 1

# Local variable
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var level_resource : LevelResource
var is_playing = false
var laughter_position = 50.0;
var additional_multiplier: int = 0;
var player_list: Dictionary
var is_singleplayer: bool = true

func _init_resources() -> void :
	multiplier_increase_frequency = level_resource.multiplier_increase_frequency
	error_amount = level_resource.error_amount
	match_amount = level_resource.match_amount
	annoyed_amount = level_resource.annoyed_amount

func _reset_on_ready() -> void :
	audio_manager = get_node("/root/Audio_Manager")
	ui_screen = get_node("/root/Game/Ui Screen")
	game_holder = get_node("/root/Game/Game Holder") 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void :
	if(is_playing):
		#additional_multiplier = int(joke_combo / multiplier_increase_frequency)
		var dead_player = _return_dead_player()
		if (dead_player):
			get_tree().call_group("ThatsAllFolks", "start", dead_player)
	pass

# Reset game manager variable to default
func reset_local_default():
	laughter_position = 50.0
	is_playing = false

# Increase Score from egg match
func register_match(distance : float, player : Comedian):
	player_list[player.player_num]["score"] += 50 * (1 + player_list[player.player_num]["joke_combo"])
	player_list[player.player_num]["joke_combo"] += 1
	_set_laugh_score(match_amount - (distance / 10) , player)

# Decrease score from wrong egg match
func register_error(player : Comedian) -> void :
	_set_laugh_score(-error_amount, player)
	player_list[player.player_num]["joke_combo"] = 0

# Decrease score from projectile hit
func register_hurt(amount : int, player : Comedian) -> void :
	player_list[player.player_num]["score"] = max(player_list[player.player_num]["score"] - amount, 0)
	_set_laugh_score(-amount, player)
	player_list[player.player_num]["joke_combo"] = 0
	
func register_annoyed() -> void :
	pass

func back_to_menu() -> void :
	player_list.clear()
	reset_local_default()
	audio_manager.stop_music();
	get_tree().paused = false
	get_tree().reload_current_scene()

func restart_level() -> void :
	player_list.clear()
	load_level(level_resource.level)

func load_level(index) -> void :
	_reset_on_ready()
	# Clear out current level
	if game_holder.get_child_count() > 0:
		for holder_scene in game_holder.get_children():
			holder_scene.queue_free()
	
	# Set level data
	level_resource = level_resource_dictionary[index]
	_init_resources()
	reset_local_default()
	
	# Add Scene and play music
	var instance = level_resource.scene.instantiate()
	game_holder.add_child(instance)
	audio_manager.play_music(int(level_resource.background_music), Shared.E_AUDIO_TYPE.BACKGROUND)
	
	is_playing = true

func add_player(comedian : Comedian) -> void :
	player_list[comedian.player_num] = {
		"player_ref" : comedian,
		"laughter" : laughter_position,
		"score" : 0,
		"joke_combo" : 0
	} 

func _return_dead_player() -> Comedian:
	for player_num in player_list.keys():
		var player = player_list[player_num]
		if (player["laughter"] == 0):
			return player["player_ref"]
	return null

func _on_shock_timer_timeout() -> void:
	is_playing = false
	get_tree().call_group("Curtains", "end_game")

func _set_laugh_score(score : float, player : Comedian) -> void :
	if (player.player_num == 1):
		laughter_position = min(100,laughter_position + score)
		player_list[player.player_num]["laughter"] = laughter_position
		player_list[2]["laughter"] = 100.0 -laughter_position
	else:
		laughter_position -= score
		player_list[1]["laughter"] = laughter_position
		player_list[player.player_num]["laughter"] = 100.0 - laughter_position
