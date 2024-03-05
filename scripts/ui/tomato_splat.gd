extends TextureRect

# Constant
var fade_speed = 0.7

# Fade Over Time
func _process(delta):
	if self.modulate.a > 0:
		self.modulate.a -= fade_speed * delta
		self.modulate.a = max(self.modulate.a, 0)  

# Set splat visible
func createSplat():
	self.modulate.a = 1 
