extends CharacterBody3D

@export var ACCEL = 0.3
@export var SPEED = 0.7
@export var JUMP_VELOCITY = 1.0
@export var INERTIA = 0.05

@onready var sprite = get_node("Sprite")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var in_spotlight = false

func on_spotlight_entered():
	in_spotlight = true
	
func on_spotlight_exited():
	in_spotlight = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_right", "move_left", "move_down", "move_up")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x += direction.x * ACCEL
	velocity.z += direction.z * ACCEL
	velocity.x = clamp(velocity.x, -SPEED, SPEED)
	velocity.z = clamp(velocity.z, -SPEED, SPEED)
	velocity.x = move_toward(velocity.x, 0, INERTIA)
	velocity.z = move_toward(velocity.z, 0, INERTIA)
	
	if (velocity.x == 0 and velocity.z == 0):
		sprite.stop()
	else:
		sprite.play('new_animation');

	move_and_slide()
