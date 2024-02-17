extends Node

# Measurement of how well peformance is going. Game over if reaches zero.
var score = 100.0;

var player_score = 0;

# Global game manager timer.
var timer = 0;
var combo = 0;

#List off all audience members
var audience_list;

#List of all hecklers
var heckler_list;


#List of all available emoji
var emoji_list = []

@export var set_time = 600;

@export var base_deplete_rate = 2;
@export var player_score_base_increase_rate = .02;
@export var player_score_increase_rate_multiplier = 1;
var spotlight_bonus = 0
@export var error_amount = 10
@export var match_amount = 10
@export var hit_amount = 20
@onready var audio_manager = get_node("/root/AudioManager")
@onready var ui_screen = get_node("/root/Game/Ui Screen")

var spotlight = false
var isPlaying = false
var time_since_last_increase = 0.0
var increase_interval = 5.0 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(isPlaying):
		
		#give a score multiplier based on spotlight status
		if(spotlight):
			spotlight_bonus = .5
		else:
			spotlight_bonus = 0
			
		score -= base_deplete_rate
		player_score += player_score_base_increase_rate * (player_score_increase_rate_multiplier + spotlight_bonus)
		
		time_since_last_increase += delta
		
		if time_since_last_increase >= increase_interval:
			player_score_increase_rate_multiplier += 0.1 
			time_since_last_increase = 0 
		
		if score <= 0:
			get_tree().call_group("ThatsAllFolks", "start")


func successful_joke_score_increase():
	if(spotlight):
		spotlight_bonus = .5
	else:
		spotlight_bonus = 0
	player_score += 50*(player_score_increase_rate_multiplier + spotlight_bonus)
	
func tomato_score_decrease():
	player_score = max(player_score-50, 0)

func exit_setting():
	reset_stats()
	isPlaying = false
	audio_manager.stop_music();
	
func reset_game():
	reset_stats()
	audio_manager.stop_music();
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/start.tscn")
	
func reset_setting():
	reset_stats()
	audio_manager.stop_music()
	audio_manager.play_music('Ragtime', 'Background')
	
func reset_stats():
	set_time = 600
	score = 100.0
	player_score = 0
	combo = 0;
	
	
func register_match():
	score += match_amount
	successful_joke_score_increase()
	combo += 1
	if (spotlight):
		audio_manager.play_music('PowerUp', 'Sound Effect')
		get_tree().call_group("AudienceManager", "destroy_all_hecklers")
	
func register_error():
	score -= error_amount
	combo = 0
	
func register_hit():
	score -= hit_amount
	tomato_score_decrease()
	combo = 0
