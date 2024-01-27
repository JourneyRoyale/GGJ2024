extends Button

var emojis = ["🤖", "👽", "🤡", "💩"]


# Called when the node enters the scene tree for the first time.
func _ready():
	emojis.shuffle();
	text = emojis[0]; 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
