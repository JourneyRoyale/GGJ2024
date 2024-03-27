extends Node3D
class_name Egg

# On Ready
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var emoji : Emoji = get_node("Emoji");
@onready var animation : AnimationPlayer = get_node("AnimationPlayer");

# Resource Variable
var switch_duration : float
var scale_duration : float
var target_scale : Vector3
var scale_ease : float

# Local Variable
var initial_scale : Vector3
var scale_time_elapsed : float = 0.0
var switch_time_elapsed : float = 0.0
var is_switching : bool = false
var is_active : bool = true

func _init_resources() -> void :
	var level_resource : LevelResource = game_manager.level_resource
	
	switch_duration = level_resource.switch_duration
	scale_duration = level_resource.scale_duration
	target_scale = level_resource.target_scale
	scale_ease = level_resource.scale_ease

func _ready() -> void :
	_init_resources()
	initial_scale = scale
	emoji.set_random_emoji()
	animation.play("default")

# Check if egg past boundary
func _process(delta : float) -> void :
	if (is_active):
		_scale_egg(delta)
		_switch_emoji(delta)

		# Check if the scaling is complete
		if scale_time_elapsed >= scale_duration:
			animation.play("late_break")
		pass

# Scale egg to target scale with easing
func _scale_egg(delta : float) -> void :
	scale_time_elapsed += delta
	# Calculate the scaling factor based on the difference between target scale and initial scale
	var scaling_factor : float = ease(scale_time_elapsed / scale_duration, scale_ease)  # Apply easing function
	# Calculate the new scale
	var new_scale : Vector3 = initial_scale + (target_scale - initial_scale) * scaling_factor
	# Set the new scale to the node
	scale = new_scale

# Switch to another emoji for egg
func _switch_emoji(delta : float) -> void :
	if (is_switching):
		switch_time_elapsed += delta
		
		if (switch_time_elapsed < (switch_duration / 4)):
			# Calculate the scaling factor based on the difference between target scale and initial scale
			var rotation_factor = ease(switch_time_elapsed / (switch_duration / 4), 1.0)  # Apply easing function
			# Calculate the new scale
			var new_rotation = 0 + (90 - 0) * rotation_factor
			
			if (new_rotation >= 85):
				emoji.set_random_emoji()
			else:
				# Set the new scale to the node
				emoji.rotation.y = deg_to_rad(new_rotation)
		
		elif (switch_time_elapsed > (switch_duration / 4)):
			# Calculate the scaling factor based on the difference between target scale and initial scale
			var rotation_factor = ease((switch_time_elapsed - (switch_duration / 4)) / (3 * switch_duration / 4), 1.0)  # Apply easing function
			# Calculate the new scale
			var new_rotation = 90 + (360 - 90) * rotation_factor
			if (new_rotation >= 355):
				_stop_switch()
			else:
				# Set the new scale to the node
				emoji.rotation.y = deg_to_rad(new_rotation)

func _stop_switch() -> void :
	if (is_switching):	
		switch_time_elapsed = 0
		is_switching = false
		emoji.rotation.y = deg_to_rad(0)

func _on_animation_player_animation_finished(anim_name : String):
	if (anim_name == "early_break" or anim_name == "late_break"):
		reset_egg()
		animation.play("default")
		emoji.show()
		is_active = true

func _on_animation_player_animation_started(anim_name):
	if (anim_name == "early_break" or anim_name == "late_break"):
		emoji.hide()

# Reset Egg
func reset_egg() -> void :
	scale = initial_scale
	scale_time_elapsed = 0.
	emoji.set_random_emoji()
	_stop_switch()

# Start switch of egg
func switch_egg() -> void :
	if (!is_switching):
		is_switching = true

# Check if timing of egg match
func timing() -> float :
	return abs(scale.x - target_scale.x)

# Check if egg is matched too early
func is_early(player : Comedian) -> bool :
	if (scale > Vector3(.8, .8, .8)):
		return false
	else:
		is_active = false
		animation.play("early_break")
		audio_manager.play_music(int(Shared.E_SOUND_EFFECT.HURT), Shared.E_AUDIO_TYPE.SOUND_EFFECT)		
		game_manager.register_error(player)
		return true


