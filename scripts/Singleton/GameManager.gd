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

@export var base_deplete_rate = 0.03;
@export var error_amount = 5
@export var match_amount = 10
@export var hit_amount = 20
@onready var audio_manager = get_node("/root/AudioManager")

var spotlight = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	score -= base_deplete_rate
	if score <= 0:
		get_tree().paused = true
		audio_manager.play_music('HitHurt', 'Sound Effect')
		await get_tree().create_timer(10).timeout
		get_tree().reload_current_scene()
		get_tree().paused = false
	
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
