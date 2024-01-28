extends Sprite2D

@export var speed = 1.0
@onready var emoji = get_node("Emoji");
@onready var animation = get_node("AnimationPlayer")
@onready var animation2 = get_node("AnimationPlayer2")
var rng = RandomNumberGenerator.new()
var emoji_num;
var isAnimationFinished = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	emoji_num = rng.randi_range(0, 7)
	emoji.set_emoji(emoji_num)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isAnimationFinished:
		position.x += speed
		if position.x == 1180:
			animation2.play("Egg Death")
			get_node("Emoji").visible = false
			get_node("Area2D").visible = false

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().call_group("AudienceManager", "check_for_match", emoji_num)
		queue_free()

func _on_animation_player_animation_finished(anim_name):
	isAnimationFinished = true;


func _on_animation_player_2_animation_finished(anim_name):
	queue_free()
