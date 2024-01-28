extends Sprite2D

@export var speed = 1.0
var emojis = ["🤖", "👽", "🤡", "💩"]
@onready var label = get_node("Label")

# Called when the node enters the scene tree for the first time.
func _ready():
	emojis.shuffle();
	label.text = emojis[0]; 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += speed

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().call_group("AudienceManager", "_receive_joke", label.text)
		queue_free()
