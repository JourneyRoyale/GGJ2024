extends Sprite2D

# On Ready
@onready var emoji = get_node("Emoji");
@onready var animation = get_node("AnimationPlayer")
@onready var middle_point = get_node("MiddlePoint")
@onready var game_manager = get_node("/root/GameManager")
# Export
@export var speed = 1.0

# Variable
var lane_index = 0;
var lifespan = 0.7
var is_fading_out = false;

func initialize(index, span):
	lane_index = index
	lifespan = span
	print("Egg initialized with index: ", lane_index)
	set_label_text(lane_index+1)
	var timer = Timer.new()
	timer.wait_time = lifespan
	timer.one_shot = true
	var callable = Callable(self, "_on_lifespan_timeout")
	timer.connect("timeout", callable)
	add_child(timer)
	timer.call_deferred("start")
	set_process_input(true)
	
func _process(delta):
	if is_fading_out and modulate.a == 0:
		is_fading_out = false  # Reset flag
		destroySelf()

func _on_lifespan_timeout():
	fade_out()

func fade_out():
	is_fading_out = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, lifespan)

# Do stuff on animation finished
func destroySelf(didTimeout = true):
	
	game_manager.free_egg_index(lane_index, didTimeout)
	queue_free()
	
func set_label_text(new_text):
	# Assuming the Label is the first child, its index is 0
	var label = get_child(0) as Label
	if label:
		label.text = str(new_text)
	else:
		print("Label not found or not a Label node.")
		
		
func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.echo:  # Ensure it's a key press event without echo
		
		var key = 0
		if(event.keycode > 4194390):
			key = event.keycode-4194390 - 48
		else:
			key = event.keycode - 48 # Get the scancode of the pressed key	
		

		print("Keycode: ", key)
		
		
		# Check if the key is between 1 and 5
		if key >= 1 and key <= 5:
			if key == lane_index + 1:
				# Run your code here
				destroySelf(false)


func handle_key_press():
	# Implement what happens when the correct key is pressed
	print("Key corresponding to lane_index+1 pressed!")
	destroySelf(false)
