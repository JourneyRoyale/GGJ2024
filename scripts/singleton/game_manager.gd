extends Node

# On Ready
@onready var audio_manager = get_node("/root/AudioManager")
@onready var ui_screen = get_node("/root/Game/Ui Screen")

# Export
@export var set_time = 600;
@export var player_score_base_increase_rate = .02;
@export var player_score_increase_rate_multiplier = 1;
@export var error_amount = 10
@export var match_amount = 10
@export var hit_amount = 20

# Variable
var spotlight = false
var isPlaying = false
var spotlight_bonus = 0
var time_since_last_increase = 0.0
var increase_interval = 5.0 
var joke_combo = 0;
var laughter_score = 50.0;
var player_score = 0;

# Lane Constraints for Hecklers and Player
var lane_x_positions = [-6, -3, 0, 3, 6];
var clamped_y_position = 1.945;
var clamped_z_position = -0.529;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(isPlaying):
		#give a score multiplier based on spotlight status
		if(spotlight):
			spotlight_bonus = .5
		else:
			spotlight_bonus = 0
			
		player_score += player_score_base_increase_rate * (player_score_increase_rate_multiplier + spotlight_bonus)
		
		time_since_last_increase += delta
		
		if time_since_last_increase >= increase_interval:
			player_score_increase_rate_multiplier += 0.1 
			time_since_last_increase = 0 
		
		if laughter_score <= 0:
			get_tree().call_group("ThatsAllFolks", "start")


func _successful_joke_score_increase():
	if(spotlight):
		spotlight_bonus = .5
	else:
		spotlight_bonus = 0
	player_score += 50*(player_score_increase_rate_multiplier + spotlight_bonus)
	
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
func register_match():
	laughter_score += match_amount
	_successful_joke_score_increase()
	joke_combo += 1
	if (spotlight):
		audio_manager.play_music('PowerUp', 'Sound Effect')
		get_tree().call_group("AudienceManager", "destroy_all_hecklers")

# Decrease score from wrong egg match
func register_error():
	laughter_score -= error_amount
	joke_combo = 0

# Decrease score from tomato hit
func register_hit():
	laughter_score -= hit_amount
	_tomato_score_decrease()
	joke_combo = 0
