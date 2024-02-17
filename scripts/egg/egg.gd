extends Sprite2D

# On Ready
@onready var emoji = get_node("Emoji");
@onready var animation = get_node("AnimationPlayer")

# Export
@export var speed = 1.0

# Variable
var emoji_num;
var isSpawned = false;
var rng = RandomNumberGenerator.new()
var isAnimationFinished = false;

# Play spawn animation and set emoji
func _ready():
	emoji_num = rng.randi_range(0, 7)
	emoji.set_emoji(emoji_num)
	animation.play("Egg Spawn")

# Check if egg past boundary
func _process(delta):
	if isSpawned:
		position.x += speed
		if position.x == 1180:
			animation.play("Egg Death")
			get_node("Emoji").visible = false
			get_node("Area2D").visible = false

# Check if egg match on click
func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().call_group("AudienceManager", "check_for_match", emoji_num)
		queue_free()

# Do stuff on animation finished
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Egg Spawn":
		isSpawned = true;
	if anim_name == "Egg Death":
		queue_free()
