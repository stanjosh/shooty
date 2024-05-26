extends AnimatedSprite2D

@export var velocity : Vector2
@onready var timer = $Timer

var opacity: int = 255

func _ready():
	if velocity.x < 0:
		flip_h = true
	play()
	


func _physics_process(delta):
	if timer.time_left:
		return
	if opacity > 0 and not timer.time_left:
		modulate.a8 = opacity
		opacity -= 255 * delta
	else:
		queue_free()
