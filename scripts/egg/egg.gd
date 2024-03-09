extends Sprite2D

# On Ready
@onready var emoji = get_node("Emoji");
@onready var animation = get_node("AnimationPlayer")
@onready var middle_point = get_node("MiddlePoint")

# Export
@export var speed = 1.0
@export var wrong_egg_additional = 2
@onready var audience_manager = get_node("/root/Game/Game Holder/Perspective/Audience")
# Variable
var emoji_num;
var isSpawned = false;
var rng = RandomNumberGenerator.new()
var isAnimationFinished = false;

# Play spawn animation and set emoji
func _ready():
	var new_audience_emoji = audience_manager.audience_emoji.duplicate()
	
	for i in range(wrong_egg_additional):
		emoji_num = rng.randi_range(0, 7)
		new_audience_emoji.append(emoji_num)
	new_audience_emoji.shuffle()
	
	emoji.set_emoji(new_audience_emoji[0])
	emoji_num = new_audience_emoji[0]
	animation.play("Egg Spawn")

# Check if egg past boundary
func _process(delta):
	if isSpawned:
		position.x += speed
		if position.x == 1180:
			animation.play("Egg Death")
			get_node("Emoji").visible = false
			get_node("Area2D").visible = false

# Do stuff on animation finished
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Egg Spawn":
		isSpawned = true;
	if anim_name == "Egg Death":
		queue_free()

func returnMiddleDistance(position):
	return abs(position.x - middle_point.global_position.x)
