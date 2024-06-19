extends Node2D

@onready var line_2d = $Line2D

@export var first_position : Vector2
@export var last_position : Vector2
@onready var zap = $zap

var fading : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	zap.pitch_scale += randf() * .3
	zap.play()
	if first_position and last_position:
		line_2d.add_point(first_position)
		line_2d.add_point(last_position)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	modulate.a -= 5 * delta
	if modulate.a <= 0:
		queue_free()


