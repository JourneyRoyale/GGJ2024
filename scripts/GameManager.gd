extends Node

# Measurement of how well peformance is going. Game over if reaches zero.
var score = 0;

# Flag for if you are actively performing the your set. 
var playing;

# Measure of audience satisfaction. Proportionally affects score rate.
var laughter = 1;

# Global game manager timer.
var timer = 0;

#List off all audience members
var audience_list;

#List of all hecklers
var heckler_list;

#List of all available emoji
var emoji_list = []

@export var set_time = 600;

@export var base_deplete_rate = 0.1;

@export var base_score_rate = 10;

@export var max_emoji = 5 

# Called when the node enters the scene tree for the first time.
func _ready():
	create_audience()
	playing = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(laughter <= 0):
		playing = false
		print("GAME OVER")
	
	if(timer >= set_time):
		print("GAME COMPLETE")
	
	poll_audience()
	
	# Score is improved proportionally to audience satisfaction and decreased inversely to how much time is left in set.
	score = score + (base_score_rate * laughter) - (base_deplete_rate * timer / set_time)
	
	
	
	if(playing):
		laughter -= .0001
		timer += delta;

#Populate the audience.
func create_audience():
	pass


# Polls all audience members in order to determine current laughter score;
func poll_audience():
	pass

#Create a heckler.
func create_heckler():
	pass
	
#Create emoji
func create_emoji(nodeReference):
	if(playing):
		emoji_list.append(nodeReference)
	
func delete_emoji(nodeReference):
	if(playing):
		if(nodeReference):
			nodeReference.queue_free()
			emoji_list.pop_front()
