extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Enum
enum AudienceEmotionalState {
	ANNOYED,
	NEUTRAL
}

# On Ready
@onready var sprite = get_node("Sprite");
@onready var emoji = get_node("Emoji3D");
@onready var bubble : AnimatedSprite3D = get_node("Bubble")
@onready var audio_manager = get_node("/root/AudioManager")
@onready var game_manager = get_node("/root/GameManager")
@onready var timer = get_node("Patience")

# Export
@export var emoji_hold = 5
@export var max_speed = 3

# Variable
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var current_emoji
var active = false
var in_progress = false
var is_seated = false
var assigned_seat
var assigned_floor
var audience_emotional_state = AudienceEmotionalState.NEUTRAL

# Const
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _physics_process(delta):
	# Fall if not on floor
	if not is_on_floor():
			velocity.y -= gravity * 100 * delta
	# If not seated, move to be seated
	if (!is_seated):
		var spawn_position = assigned_seat.get_node("Spawn Point").global_transform.origin
		sprite.play("walking")
		in_progress = true
		
		# Move down then left or right to audience assigned seat
		if(global_transform.origin.z != spawn_position.z):
			_move_down(delta, spawn_position)
		elif(global_transform.origin.x != spawn_position.x):
			_move_to_seat(delta, spawn_position)
		else:
			is_seated = true
			sprite.play("sitting")
		
	move_and_slide()

# Move down the stair to chair floor
func _move_down(delta, spawn_position):
	var distance_to_target = abs(global_transform.origin.z - spawn_position.z)
	
	if distance_to_target > 1:
		velocity.z += SPEED * delta
		velocity.z = min(velocity.z, max_speed)
	else:
		global_transform.origin.z = spawn_position.z
		velocity.z = 0
		

# Move to the seat of the chair
func _move_to_seat(delta, spawn_position):
	var distance_to_target = abs(global_transform.origin.x - spawn_position.x)
	
	if distance_to_target > 1:
		if (global_transform.origin.x < spawn_position.x):
			velocity.x += SPEED * delta
			velocity.x = min(velocity.x, max_speed)
		elif (global_transform.origin.x > spawn_position.x):
			velocity.x -= SPEED * delta
			velocity.x = min(velocity.x, max_speed)
	else:
		global_transform.origin.x = spawn_position.x
		velocity.x = 0

# Change Bubble animation base on finished animation
func _on_bubble_animation_finished():
	var current_animation = bubble.get_animation()
	if(current_animation == "showing"):
		bubble.play("show")
		emoji.show()
		timer.start(emoji_hold)
	if(current_animation == "bad"):
		clear_emoji()
		bubble.play("blank")

# Change Sprite animation base on finished animation
func _on_animation_finished():
	if (sprite.animation == "laughing"):
		sprite.play("sit")
	if (sprite.animation == "sitting"):
		sprite.play("sit")
		in_progress = false

# When audience patience runs out
func _on_patience_timeout():
	if(sprite.animation == "annoyed"):
		get_tree().call_group("AudienceManager", "spawn_heckler", self)
	else:	
		emoji.hide()
		bubble.play("bad")
		sprite.play("annoyed")

# Show Emoji
func show_emoji():
	if (!in_progress and is_seated and !active):
		in_progress = true
		active = true
		current_emoji = randi_range(0, 7)
		emoji.set_emoji(current_emoji)
		bubble.play("showing")
		bubble.show()

# Clear out emoji
func clear_emoji():
	in_progress = false
	active = false
	bubble.hide()
	emoji.hide()

# Check if emoji provided match with current
func check_for_match(emoji):
	if (active):
		var match = emoji == current_emoji
		var success = match
		if success:
			clear_emoji()
			sprite.play("laughing")
		return success

