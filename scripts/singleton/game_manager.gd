extends Node

# On Ready
@onready var audio_manager = get_node("/root/AudioManager")
@onready var ui_screen = get_node("/root/Game/Ui Screen")

# Export
@export var set_time = 600;
#Commenting out just in case we want to re-implement gradually increasing score	
#@export var player_score_base_increase_rate = .02;
#@export var player_score_increase_rate_multiplier = 1;
@export var multiplier_increase_frequency: int = 3; #How many jokes in the combo before multiplier goes up
@export var error_amount = 10
@export var match_amount = 10
@export var hit_amount = 20
@export var annoyed_amount = 1
@export var additional_multiplier: int = 0;
@export var joke_combo: int = 0;

# Variable
var spotlight = false
var isPlaying = false
var spotlight_bonus = 0
var time_since_last_increase = 0.0
var increase_interval = 5.0 

var laughter_score = 50.0;
var player_score = 0;

# Lane Constraints for Player and Heckler
var lane_x_positions = [-6, -3, 0, 3, 6];
var heckler_lane_x_positions = [-6.2, -4.8, -1.8, 1.2, 4.2];
var filled_lane_x_positions = [false, false, false, false, false]

var clamped_y_position = 1.945;
var clamped_z_position = -0.529;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(isPlaying):
		#give a score multiplier based on spotlight status
		#if(spotlight):
		#	spotlight_bonus = .5
		#else:
		#	spotlight_bonus = 0
		
		#Commenting out just in case we want to re-implement gradually increasing score	
		#player_score += player_score_base_increase_rate * (player_score_increase_rate_multiplier + spotlight_bonus)
		
		#time_since_last_increase += delta
		
		#if time_since_last_increase >= increase_interval:
		#	player_score_increase_rate_multiplier += 0.1 
		#	time_since_last_increase = 0 
		additional_multiplier = (joke_combo / multiplier_increase_frequency)
		additional_multiplier = int(additional_multiplier)
		
		if laughter_score <= 0:
			get_tree().call_group("ThatsAllFolks", "start")


func _successful_joke_score_increase():
	#if(spotlight):
	#	spotlight_bonus = .5
	#else:
	#	spotlight_bonus = 0
	player_score += 50 * (1 + additional_multiplier)
	
func _tomato_score_decrease():
	player_score = max(player_score-50, 0)

# Reset after pause exiting game
func exit_setting():
	reset_default()
	isPlaying = false
	audio_manager.stop_music();

# Reset after game over
func reset_game():
	reset_default()
	audio_manager.stop_music();
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/start.tscn")

# Reset on pause Restart
func reset_setting():
	reset_default()
	audio_manager.stop_music()
	audio_manager.play_music('Ragtime', 'Background')

# Reset game manager variable to default
func reset_default():
	set_time = 600
	laughter_score = 50.0
	player_score = 0
	joke_combo = 0;

# Increase Score from egg match
func register_match(distance):
	laughter_score += match_amount - (distance / 10) 
	_successful_joke_score_increase()
	joke_combo += 1
	get_tree().call_group("AudienceManager", "hurt_all_hecklers")

# Decrease score from wrong egg match
func register_error():
	laughter_score -= error_amount
	joke_combo = 0

# Decrease score from tomato hit
func register_hit():
	laughter_score -= hit_amount
	_tomato_score_decrease()
	joke_combo = 0
	
func register_annoyed():
	laughter_score -= annoyed_amount
	joke_combo = 0
