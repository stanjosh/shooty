extends Node2D

@onready var line_2d = $Line2D

@export var first_position : Vector2
@export var last_position : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	line_2d.add_point(first_position)
	line_2d.add_point(last_position)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	modulate.a -= 2 * delta
	if modulate.a <= 0:
		queue_free()