extends SpotLight3D

var target_position = Vector3(1, 0.512, 1);
var target_x_range = [-0.367, 0.336]
var target_z_range = [-0.129, -0.5]
# TODO: replace with singleton RNG
var rng = RandomNumberGenerator.new()

func _ready():
	select_new_target_position()

func select_new_target_position():
	target_position.x = rng.randf_range(target_x_range[0], target_x_range[1])
	target_position.z = rng.randf_range(target_z_range[0], target_z_range[1])
	#TODO: enforce a particular min distance to move so we don't get micromovements

func _process(delta):
	position = lerp(position, target_position, delta)
	if (position.distance_to(target_position) < 0.01):
		#TODO: wait
		select_new_target_position()