extends Area3D

# Constants
var MOVE_SPEED = 1.0
var MOVE_TIME_MIN = 2.0
var MOVE_TIME_MAX = 5.0
var AGGRESSIVENESS = 0.5 # TO-DO - implement aggressiveness variable that causes heckler to stop early in front of player
var LEFT_BOUNDARY = -7
var RIGHT_BOUNDARY = 7
var THROW_DELAY = 0.6 #how long the heckler pauses to throw a tomato in seconds

# Variables
var move_time = 0.0
var move_timer = 0.0
var is_moving = true
var current_direction = Vector3(1.0, 0, 0).normalized()  # Starts moving right
@onready var animation_player = get_node("AnimationPlayer")
@onready var sprite = get_node("AnimatedSprite3D")

var audience_reference

var packed_projectile = load("res://prefab/Projectile.tscn")
@onready var audio_manager = get_node("/root/AudioManager")

func _ready():
	sprite.play("default")
	randomize()
	start_moving()

func _process(delta):
	if is_moving:
		position += current_direction * MOVE_SPEED * delta * 5
		move_timer += delta
		if move_timer > move_time:
			stop_moving()

		# Check boundaries
		if position.x <= LEFT_BOUNDARY and current_direction.x < 0:
			current_direction.x = -current_direction.x  # Change to moving right
		elif position.x >= RIGHT_BOUNDARY and current_direction.x > 0:
			current_direction.x = -current_direction.x  # Change to moving left


func start_moving():
	is_moving = true
	animation_player.play("bounce")
	sprite.play("default")
	move_time = randf_range(MOVE_TIME_MIN, MOVE_TIME_MAX)
	move_timer = 0.0

func stop_moving():
	animation_player.stop()
	is_moving = false
	throw_tomato()

func throw_tomato():
	animation_player.play("throw")
	sprite.play("throw")
	if randi() % 2 == 0:
		current_direction.x = 1.0  # Move right
	else:
		current_direction.x = -1.0  # Move left
	print("Throwing a tomato!")

	is_moving = false
	var timer = Timer.new()  
	timer.wait_time = THROW_DELAY  # Set the wait time (1.5 seconds)
	timer.one_shot = true  # Make sure it only ticks once
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.name = "HecklerTimer"  # Naming the timer for easier identification
	
	add_child(timer)  # Add the timer to the node tree
	timer.start()
	
func _on_timer_timeout():
	print("Timer completed, resuming movement")
	var instance = packed_projectile.instantiate()
	# Add the projectile as a sibling rather than a child
	if get_parent():
		get_parent().add_child(instance)
		instance.global_transform = global_transform 
		
	start_moving()
	
	var timer_node = get_node("HecklerTimer")
	if timer_node:
		timer_node.queue_free()  # Safely remove the timer node

