extends AnimatedSprite3D

#TODO: make this global
var emojis = ["🤖", "👽", "🤡", "💩"]
@export var emoji_time = 5.0
@export var thinking_time = 1.0
@onready var label = get_node("Label3D")
@onready var bubble : AnimatedSprite3D = get_node("Bubble")

var current_emoji

var bubble_alignment = BubbleAlignment.BLANK

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

const bad_emoji_rate : float = 0.25

enum BubbleAlignment {BLANK, GOOD, BAD}

# Called when the node enters the scene tree for the first time.
func _ready():
	rotate_emoji()

func get_bubble_alignment():
	return bubble_alignment
	
func get_current_emoji():
	return label.text
	
func clear_thought():
	label.text = ""
	bubble.play("blank")
	bubble_alignment = BubbleAlignment.BLANK
	bubble.hide()
	
func show_thought():
	var alignment = rng.randf_range(0, 1)
	if alignment < bad_emoji_rate:
		show_bad_thought()
	else:
		show_good_thought()
		
func show_good_thought():
	emojis.shuffle()
	label.text = emojis[0]
	bubble.show()
	bubble_alignment = BubbleAlignment.GOOD
	bubble.play("good")

		
func show_bad_thought():
	emojis.shuffle()
	label.text = emojis[0]
	bubble.show()
	bubble_alignment = BubbleAlignment.BAD
	bubble.play("bad")
	
func rotate_emoji():
	show_thought()
	await get_tree().create_timer(emoji_time).timeout
	clear_thought()
	await get_tree().create_timer(thinking_time).timeout
	rotate_emoji()
	
func check_for_match(emoji):
	var success = emoji == label.text && bubble_alignment != BubbleAlignment.BAD && bubble_alignment != BubbleAlignment.BLANK
	if success:
		label.text = "🤩"
	else:
		label.text = "😡"
	return { 
		"success" : success,
		"heckler" : bubble_alignment == BubbleAlignment.BAD
		}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
