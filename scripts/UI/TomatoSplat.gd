extends TextureRect

var fade_speed = 0.7

func createSplat():
	print("Splat created")
	self.modulate.a = 1 

func _process(delta):
	if self.modulate.a > 0:
		print("Depleting! Current value: ", self.modulate.a)
		self.modulate.a -= fade_speed * delta
		self.modulate.a = max(self.modulate.a, 0)  
