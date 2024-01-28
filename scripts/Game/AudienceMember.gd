extends AnimatedSprite3D

#TODO: make this global
var emojis = ["🤖", "👽", "🤡", "💩"]
@export var cooldown = .5
@onready var label = get_node("Label3D")
@onready var bubble : AnimatedSprite3D = get_node("Bubble")

var current_emoji

var bubble_alignment = BubbleAlignment.BLANK

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

const bad_emoji_rate : float = 0.25

enum BubbleAlignment {BLANK, GOOD, BAD}

var active = false

var is_cooldown = false
	
#region Show Random Thought
func show_thought(time):
	var alignment = rng.randf_range(0, 1)
	if alignment < bad_emoji_rate:
		show_bad_thought(time)
	else:
		show_good_thought(time)
		
func show_random_thought_helper():
	active = true
	emojis.shuffle()
	label.text = emojis[0]
	bubble.show()
	
		
func show_good_thought(time):
	show_random_thought_helper()
	bubble_alignment = BubbleAlignment.GOOD
	bubble.play("good")
	await get_tree().create_timer(time).timeout
	if active:
		clear_thought()

func show_bad_thought(time):
	show_random_thought_helper()
	bubble_alignment = BubbleAlignment.BAD
	bubble.play("bad")
	await get_tree().create_timer(time).timeout
	if active:
		clear_thought()
#endregion
	
#region Show Specific Thought
func specific_thought(thought, time):
	var alignment = rng.randf_range(0, 1)
	if alignment < bad_emoji_rate:
		specific_bad_thought(thought, time)
	else:
		specific_good_thought(thought, time)

func show_specific_thought_helper(thought):
	active = true
	label.text = emojis.find(thought)
	bubble.show()
	
func specific_good_thought(thought, time):
	show_specific_thought_helper(thought)
	bubble_alignment = BubbleAlignment.GOOD
	bubble.play("good")
	await get_tree().create_timer(time).timeout
	if active:
		clear_thought()

func specific_bad_thought(thought, time):
	show_specific_thought_helper(thought)
	bubble_alignment = BubbleAlignment.BAD
	bubble.play("bad")
	await get_tree().create_timer(time).timeout
	if active:
		clear_thought()
#endregion
	
# Called when the node enters the scene tree for the first time.
func _ready():
	print("audience member: 'hello world'")
	label.text = ""

func get_bubble_alignment():
	return bubble_alignment
	
func get_current_emoji():
	return label.text
	
func clear_thought():
	label.text = ""
	bubble.play("blank")
	bubble_alignment = BubbleAlignment.BLANK
	bubble.hide()
	active = false
	is_cooldown = true
	print("cooldown")
	await get_tree().create_timer(cooldown).timeout
	is_cooldown = false
	
	
func check_for_match(emoji):
	var success = emoji == label.text && bubble_alignment != BubbleAlignment.BAD && bubble_alignment != BubbleAlignment.BLANK
	if success:
		specific_good_thought("🤩", cooldown)
	return { 
		"success" : success && active,
		"heckler" : success && bubble_alignment == BubbleAlignment.BAD && active
	}
		
