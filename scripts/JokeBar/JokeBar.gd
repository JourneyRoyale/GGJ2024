extends HBoxContainer

var packed_joke_button = load("res://prefab/JokeButton.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_joke()

func add_joke():
	await get_tree().create_timer(1).timeout
	var instance = packed_joke_button.instantiate()
	add_child(instance)
	add_joke()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
