extends AnimatedSprite3D

#TODO: make this global
@export var cooldown = .5
@onready var label = get_node("Label3D")
@onready var emoji = get_node("Emoji3D");
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
	current_emoji = randi_range(0, 7)
	emoji.set_emoji(current_emoji)
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
	emoji.set_emoji(thought)
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

func get_bubble_alignment():
	return bubble_alignment
	
func get_current_emoji():
	return current_emoji
	
func clear_thought():
	emoji.reset_emojis()
	bubble.play("blank")
	bubble_alignment = BubbleAlignment.BLANK
	bubble.hide()
	active = false
	is_cooldown = true
	print("cooldown")
	await get_tree().create_timer(cooldown).timeout
	is_cooldown = false
	
	
func check_for_match(emoji):
	var match = active && emoji == current_emoji
	var success = match && bubble_alignment == BubbleAlignment.GOOD
	if success:
		#TODO: show success emote for audience
		pass
	return { 
		"success" : success,
		"heckler" : match && bubble_alignment == BubbleAlignment.BAD
	}
		
