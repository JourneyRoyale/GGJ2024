extends Sprite2D

@export var speed = 1.0
@onready var emoji = get_node("Emoji");
var rng = RandomNumberGenerator.new()
var emoji_num;

# Called when the node enters the scene tree for the first time.
func _ready():
	emoji_num = rng.randi_range(0, 7)
	emoji.set_emoji(emoji_num)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += speed
	if position.x > 1920:
		queue_free()

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().call_group("AudienceManager", "check_for_match", emoji_num)
		queue_free()
