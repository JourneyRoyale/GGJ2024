extends TextureRect
class_name TomatoSplat

# Local Variable
var fade_speed : float

# Fade Over Time
func _process(delta):
	if self.modulate.a > 0:
		self.modulate.a -= fade_speed * delta
		self.modulate.a = max(self.modulate.a, 0)  

# Set splat visible
func createSplat(fade_speed : float):
	self.modulate.a = 1 
	self.fade_speed = fade_speed
