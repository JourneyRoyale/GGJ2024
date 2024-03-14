extends Node
class_name GameManager

# On Ready
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var ui_screen = get_node("/root/Game/Ui Screen")
@onready var game_holder = get_node("/root/Game/Game Holder")

# Export
@export var level_resource_dictionary : Dictionary = {}

# Init variable from resources
var multiplier_increase_frequency : int = 3; #How many jokes in the combo before multiplier goes up
var error_amount : int = 10
var match_amount : int = 10
var hit_amount : int = 20
var annoyed_amount : int = 1

# Local variable
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var level_resource : LevelResource
var is_playing = false
var laughter_score = 50.0;
var player_score = 0;
var joke_combo: int = 0;
var additional_multiplier: int = 0;
var heckler_lane_x_positions = [-6.2, -4.8, -1.8, 1.2, 4.2];
var filled_lane_x_positions = [false, false, false, false, false]

func _init_resources() -> void :
	multiplier_increase_frequency = level_resource.multiplier_increase_frequency
	error_amount = level_resource.error_amount
	match_amount = level_resource.match_amount
	hit_amount = level_resource.hit_amount
	annoyed_amount = level_resource.annoyed_amount

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void :
	if(is_playing):
		additional_multiplier = int(joke_combo / multiplier_increase_frequency)
		
		if laughter_score <= 0:
			get_tree().call_group("ThatsAllFolks", "start")

# Reset game manager variable to default
func reset_local_default():
	laughter_score = 50.0
	player_score = 0
	joke_combo = 0;
	is_playing = false

# Increase Score from egg match
func register_match(distance):
	player_score += 50 * (1 + additional_multiplier)
	laughter_score += match_amount - (distance / 10) 
	joke_combo += 1

# Decrease score from wrong egg match
func register_error() -> void :
	laughter_score -= error_amount
	joke_combo = 0

# Decrease score from tomato hit
func register_hurt() -> void :
	player_score = max(player_score-50, 0)
	laughter_score -= hit_amount
	joke_combo = 0
	
func register_annoyed() -> void :
	laughter_score -= annoyed_amount

func back_to_menu() -> void :
	reset_local_default()
	audio_manager.stop_music();
	get_tree().paused = false
	get_tree().reload_current_scene()

func restart_level() -> void :
	load_level(level_resource.level)

func load_level(index) -> void :
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
	audio_manager.play_music(level_resource.background_music, Shared.E_AudioType.BACKGROUND)
	
	is_playing = true
