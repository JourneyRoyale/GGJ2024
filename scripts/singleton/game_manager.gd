extends Node

# On Ready
@onready var audio_manager = get_node("/root/AudioManager")
@onready var ui_screen = get_node("/root/Game/Ui Screen")
@onready var game_ui = get_node("/root/Game/Ui Screen/GameUI")

# Export
@export var set_time = 600;
#Commenting out just in case we want to re-implement gradually increasing score	
#@export var player_score_base_increase_rate = .02;
#@export var player_score_increase_rate_multiplier = 1;
@export var multiplier_increase_frequency: int = 3; #How many jokes in the combo before multiplier goes up
@export var error_amount = 10
@export var match_amount = 10
@export var hit_amount = 20
@export var additional_multiplier: int = 0;
@export var joke_combo: int = 0;

# On Ready
@onready var packed_egg = load("res://prefab/egg/egg.tscn")

# Variable
var spotlight = false
var isPlaying = false
var spotlight_bonus = 0
var time_since_last_increase = 0.0
var increase_interval = 5.0 

var laughter_score = 50.0;
var player_score = 0;


# Lane Constraints for Player and Heckler
var lane_x_positions = [-5.7, -3, 0, 3, 6];

var heckler_lane_x_positions = [-6.2, -4.8, -1.8, 1.2, 4.2];
var filled_lane_x_positions = [false, false, false, false, false]

var egg_lane_x_positions = [400, 675, 950, 1250, 1500]
var egg_filled_lane_x_positions = [false, false, false, false, false]

var clamped_y_position = 1.945;
var clamped_z_position = -0.529;

#Egg Spawn Timer
func _ready():
	var timer = Timer.new()  
	timer.wait_time = 1.5
	timer.one_shot = true  # Make sure it only ticks once
	timer.connect("timeout", Callable(self, "spawn_egg"))
	timer.name = "ThrowTimer"  # Naming the timer for easier identification
	add_child(timer)  # Add the timer to the node tree
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(isPlaying):
		additional_multiplier = (joke_combo / multiplier_increase_frequency)
		additional_multiplier = int(additional_multiplier)
		
		if laughter_score <= 0:
			get_tree().call_group("ThatsAllFolks", "start")


func _successful_joke_score_increase():
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
func register_match():
	laughter_score += 10
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


func spawn_egg():
	var available_positions = []
	for i in range(egg_filled_lane_x_positions.size()):
		if not egg_filled_lane_x_positions[i]:
			available_positions.append(i)
	
	if available_positions.size() > 0:
		var chosen_index = available_positions[randi() % available_positions.size()]
		egg_filled_lane_x_positions[chosen_index] = true
		
		var egg_instance = packed_egg.instantiate()
		egg_instance.initialize(chosen_index, .5)
		game_ui.add_child(egg_instance)
		egg_instance.global_transform.origin.x = egg_lane_x_positions[chosen_index]
		egg_instance.global_transform.origin.y = 950 # Replace with your Y
		
	var timer = Timer.new()  
	timer.wait_time = 1.5
	timer.one_shot = true 
	timer.connect("timeout", Callable(self, "spawn_egg"))
	timer.name = "ThrowTimer"
	add_child(timer)
	timer.start()

func free_egg_index(lane_index, didTimeout):
	if(didTimeout):
		register_error();
	else:
		register_match();
		audio_manager.play_music('PickupCoin', 'Sound Effect')

	print("Freed lane index ", lane_index)
	egg_filled_lane_x_positions[lane_index] = false
