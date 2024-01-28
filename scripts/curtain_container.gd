extends Node2D

@onready var left : AnimatedSprite2D = get_node("LeftCurtain")
@onready var right : AnimatedSprite2D = get_node("RightCurtain")

func end_game():
	left.play("closing")
	right.play("closing")
	pass
	
func start_game():
	left.play("opening")
	right.play("opening")
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	left.play("closed")
	right.play("closed")

func _on_left_curtain_animation_finished(anim_name):
	print("ANIM " + anim_name)
	if anim_name == "closing":
		left.play("closed")
	if anim_name == "opening":
		left.play("open")


func _on_right_curtain_animation_finished(anim_name):
	print("ANIM " + anim_name)
	if anim_name == "closing":
		right.play("closed")
	if anim_name == "opening":
		right.play("open")
