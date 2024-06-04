extends Node2D

@onready var line_2d = $Line2D

@export var first_position : Vector2
@export var last_position : Vector2

var fading : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if first_position and last_position:
		line_2d.add_point(first_position)
		line_2d.add_point(last_position)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fading:
		modulate.a -= 1 * delta
	if modulate.a <= 0:
		queue_free()


func _on_timer_timeout():
	fading = true
