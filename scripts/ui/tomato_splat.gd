extends TextureRect
class_name TomatoSplat

# Local Variable
var fade_time_elapsed : float = 0
var fade_duration : float
var fade_ease : float

# Fade Over Time
func _process(delta):
	if self.modulate.a > 0:
		fade_time_elapsed += delta
		# Calculate the scaling factor based on the difference between target scale and initial scale
		var fade_factor : float = ease(fade_time_elapsed / fade_duration, fade_ease)  # Apply easing function
		# Calculate the new scale
		var modulate : float = 1 + (0 - 1) * fade_factor
		# Set the new scale to the node
		self.modulate.a = modulate
		self.modulate.a = max(self.modulate.a, 0)  

# Set splat visible
func createSplat(fade_modification : Dictionary):
	self.modulate.a = 1 
	self.fade_duration = fade_modification["fade_duration"]
	self.fade_ease = fade_modification["fade_ease"]
	fade_time_elapsed = 0
