extends AnimatedSprite3D

#TODO: make this global
var emojis = ["🤖", "👽", "🤡", "💩"]
@export var emoji_time = 5.0
@export var thinking_time = 1.0
@onready var label = get_node("Label3D")

# Called when the node enters the scene tree for the first time.
func _ready():
	rotate_emoji()
		
func rotate_emoji():
	emojis.shuffle()
	label.text = emojis[0]
	await get_tree().create_timer(emoji_time).timeout
	label.text = "..."
	await get_tree().create_timer(thinking_time).timeout
	rotate_emoji()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
