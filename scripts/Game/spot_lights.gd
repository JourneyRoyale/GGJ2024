extends Node3D

# On Ready
@onready var particles : CPUParticles3D = get_node("Ground/CPUParticles3D")
@onready var game_manager = get_node("/root/GameManager")

# Export
@export var minDistance = 5
@export var spotlightWaitTime = 2.5

# Variable
var target_position = Vector3(1, 2.322, 1);
var target_x_range = [-7.0, 7.0]
var target_z_range = [-3.5, 0.47]
var active = false
var spotlightWaitingTimer = 0
var moving = false
var rng = RandomNumberGenerator.new()

func _ready():
	select_new_target_position()
	spawn()

func _process(delta):
	if(!moving):
		spotlightWaitingTimer += delta;
	
	if(spotlightWaitingTimer >= spotlightWaitTime):
		select_new_target_position()
		spotlightWaitingTimer = 0
	
	if(moving):
		position = lerp(position, target_position, delta)
		
		if (position.distance_to(target_position) < 0.1):
			moving = false;

func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		particles.emitting = true
		game_manager.spotlight = true

func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		particles.emitting = false
		game_manager.spotlight = false

func select_new_target_position():
	while (position.distance_to(target_position) < minDistance):
		target_position.x = rng.randf_range(target_x_range[0], target_x_range[1])
		target_position.z = rng.randf_range(target_z_range[0], target_z_range[1])
	
	moving = true;

func despawn():
	hide()
	active = false
	
func spawn():
	show()
	active = true
