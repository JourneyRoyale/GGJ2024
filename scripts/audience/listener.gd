extends CharacterBody3D
class_name Listener

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var sprite : AnimatedSprite3D = get_node("AnimatedSprite3D");
@onready var emoji : Emoji = get_node("Emoji");
@onready var bubble : AnimatedSprite3D = get_node("Bubble")
@onready var timer : Timer = get_node("Patience")

# Init Variable
var modification : Dictionary
var is_seated : bool = false

# Resource Variable
var patience : int
var move_speed : float
var can_sit : bool

# Local variable
var has_emoji : bool = false
var is_busy : bool = false
var assigned_chair : Chair

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Constant
const SPEED : float = 5.0

func init_variable(modificaiton : Dictionary, is_seated : bool) -> void :
	self.modification = modificaiton
	self.is_seated = is_seated
	
	patience = modification["listener"]["patience"]
	move_speed = modification["listener"]["move_speed"]
	can_sit = modification["listener"]["can_sit"]

func _ready():
	sprite.sprite_frames = modification["listener"]["sprite_frame"]
	_seat_listener()

func _physics_process(delta : float) -> void :
	# Fall if not on floor
	if not is_on_floor():
			velocity.y -= gravity * 2 * delta
	
	# If not seated, move to be seated
	if (!is_seated and can_sit):
		var spawn_position : Vector3 = assigned_chair.get_chair_position()
		
		# Move down then left or right to listener assigned seat
		if(global_transform.origin.z != spawn_position.z):
			_move_down(delta, spawn_position)
		elif(global_transform.origin.x != spawn_position.x):
			_move_to_seat(delta, spawn_position)
		else:
			_seat_on_chair()
		
	move_and_slide()

# If seated then neutral, else walk to chair
func _seat_listener():
	if (is_seated):
		sprite.play("neutral")
	else:
		sprite.play("walking")

# Move down the stair to chair floor
func _move_down(delta : float, spawn_position : Vector3) -> void :
	var distance_to_target : float = abs(global_transform.origin.z - spawn_position.z)
	
	if distance_to_target > 1:
		velocity.z += SPEED * delta
		velocity.z = min(velocity.z, move_speed)
	else:
		global_transform.origin.z = spawn_position.z
		velocity.z = 0

# Move to the seat of the chair
func _move_to_seat(delta : float, spawn_position : Vector3) -> void :
	var distance_to_target : float = abs(global_transform.origin.x - spawn_position.x)
	
	if distance_to_target > 1:
		if (global_transform.origin.x < spawn_position.x):
			velocity.x += SPEED * delta
			velocity.x = min(velocity.x, move_speed)
		elif (global_transform.origin.x > spawn_position.x):
			velocity.x -= SPEED * delta
			velocity.x = min(velocity.x, move_speed)
	else:
		global_transform.origin.x = spawn_position.x
		velocity.x = 0

# Set listener to seated
func _seat_on_chair() -> void :
	is_seated = true
	sprite.play("sitting")

# Change Bubble animation base on finished animation
func _on_bubble_animation_finished() -> void :
	var current_animation : String = bubble.get_animation()
	if(current_animation == "showing"):
		_show_emoji()
	if(current_animation == "bad"):
		_clear_emoji()

# Change Sprite animation base on finished animation
func _on_animation_finished() -> void :
	var current_animation : String = sprite.get_animation()
	if (current_animation == "laughing"):
		_reset_listener()
	if (current_animation == "sitting"):
		_reset_listener()

# When listener patience runs out
func _on_patience_timeout() -> void :
	if(sprite.animation == "annoyed"):
		# If heckler max is not reach
		get_tree().call_group("AudienceManager", "spawn_heckler", self)
		# Otherwise
		_annoy_listener()
		game_manager.register_annoyed()
	else:	
		_annoy_listener()

# Toggle Bubble and showing animation
func _start_showing_emoji() -> void :
	bubble.play("showing")
	bubble.show()

# Bubble is in the show state, show emoji and start listener patience
func _show_emoji() -> void :
	has_emoji = true
	bubble.play("show")
	emoji.show()
	timer.start(patience)

# Annoy the listener
func _annoy_listener() -> void :
	emoji.hide()
	bubble.play("bad")
	sprite.play("annoyed")

# Clear out emoji
func _clear_emoji() -> void :
	is_busy = false
	has_emoji = false
	bubble.hide()
	emoji.hide()
	emoji.reset_emojis()

# Return listener back to neutral
func _reset_listener() -> void :
	sprite.play("neutral")
	is_busy = false

# Start animation to move to seat and set status
func move_to_seat() -> void :
	sprite.play("walking")
	is_seated = false
	is_busy = true
	
# Show Emoji
func show_emoji(emoji_variety : Array[Shared.E_Emoji]) -> void :
	if (!is_busy and is_seated and emoji.current_emoji != null):
		is_busy = true
		emoji.set_random_emoji_variety(emoji_variety)
		_start_showing_emoji();

# Check if emoji provided match with current
func check_for_match(egg_emoji : Shared.E_Emoji) -> bool :
	if (has_emoji):
		var match : bool = egg_emoji == emoji.current_emoji
		if match:
			_clear_emoji()
			sprite.play("laughing")
		return match
	
	return false

