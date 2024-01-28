extends Node

# Measurement of how well peformance is going. Game over if reaches zero.
var score = 50.0;
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
@export var error_amount = 10
@export var match_amount = 10
@export var hit_amount = 20
@onready var audio_manager = get_node("/root/AudioManager")
@onready var ui_screen = get_node("/root/Game/Ui Screen")

var spotlight = false
var isPlaying = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(isPlaying):
		score -= base_deplete_rate
		timer += delta;
		if score <= 0:
			get_tree().call_group("ThatsAllFolks", "start")
			#get_tree().paused = true
			#audio_manager.play_music('HitHurt', 'Sound Effect')
			#await get_tree().create_timer(5).timeout
			#get_tree().reload_current_scene()
			#reset_setting()
			#get_tree().paused = false
	
func exit_setting():
	reset_stats()
	isPlaying = false
	audio_manager.stop_music();
	
func reset_game():
	reset_stats()
	audio_manager.stop_music();
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Start.tscn")
	ui_screen.game_ui.visible = false
	
func reset_setting():
	reset_stats()
	audio_manager.stop_music()
	audio_manager.play_music('Ragtime', 'Background')
	
func reset_stats():
	set_time = 600
	score = 50.0
	timer = 0;
	combo = 0;
	
	
func register_match():
	score += match_amount
	combo += 1
	if (spotlight):
		audio_manager.play_music('PowerUp', 'Sound Effect')
		get_tree().call_group("AudienceManager", "destroy_all_hecklers")
	
func register_error():
	score -= error_amount
	combo = 0
	
func register_hit():
	score -= hit_amount
	combo = 0
