extends TextureRect

@export var fadeDuration = 0.5;
@export var fadeAmount = 0.0;

@export var targetPosition = Vector2(0.0, 0.0);

@export var aspect = float(1.0);
@export var tiling = Vector2(1.0, 1.0);
@export var offset = Vector2(0.0, 0.0);
@export var hypotenuse = float(1.0);

func _ready():
	#_calculateAspect();
	_calculateOffset();
	_calculateHypotenuse();
	visible = true
	fadeIn();
	pass 

func _process(delta):
	_setShaderParameters();
	pass

func _getNormalizedScreenPosition(screenPos):
	screenPos.x /= get_viewport().size.x;
	screenPos.y /= get_viewport().size.y;
	return screenPos;
	
func _fadeOut():
	_calculateOffset();
	_calculateHypotenuse();
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "fadeAmount", 1, fadeDuration);
	tween.tween_callback(Callable(self,"fadeIn"))
	pass
	
func fadeIn():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "fadeAmount", 0, fadeDuration);
	tween.tween_callback(Callable(self,"visible_off"))
	pass

func visible_off():
	self.visible = false

func _calculateAspect():
	var size = get_viewport().size;
	if(size.x > size.y):
		aspect = size.x / size.y;
		tiling.x = aspect;
		tiling.y = 1;
	else:
		aspect = size.y / size.x;
		tiling.y = aspect;
		tiling.x = 1;
	pass

func _calculateOffset():
	offset = targetPosition;
	
	if(get_viewport().size.x > get_viewport().size.y):
		offset.x *= aspect;
	else:
		offset.y *= aspect;
		
	pass

func _calculateHypotenuse():
	var x = offset.x;
	var y = offset.y;
	
	var screenCenterNormalized = Vector2(0.5, 0.5);
	if(get_viewport().size.x > get_viewport().size.y):
		screenCenterNormalized.x *= aspect;
	else:
		screenCenterNormalized.y *= aspect;
	
	# fade out center is in the left portion of the screen, calculate distance to the right side of the screen
	if(x < screenCenterNormalized.x):
		x = screenCenterNormalized.x * 2  - x;
	# fade out center is in the top portion of the screen, calculate distance to the bottom side of the screen
	if(y < screenCenterNormalized.y):
		y = screenCenterNormalized.y * 2  - y;
	
	hypotenuse = sqrt(x * x + y * y);
	
	pass

func _setShaderParameters():
	self.material.set_shader_parameter("fadeAmount", fadeAmount);
	self.material.set_shader_parameter("hypotenuse", hypotenuse);
	self.material.set_shader_parameter("offset", offset);
	self.material.set_shader_parameter("tiling", tiling);
	pass
