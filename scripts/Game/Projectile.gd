extends Area3D

@export var SPEED = 0.01

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.z += SPEED


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.projectile_collided()
		#TODO: Let gamemanager know
