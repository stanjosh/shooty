extends Node2D

@onready var floating_label = $FloatingLabel
@onready var display_time = $display_time

var display_value : String
var value
var endpoint : Vector2
var vector: float

func _ready():
	if value is int and value >= 2:
		display_value = "%s" % value
	elif value is String:
		display_value = value
	endpoint = Vector2( -12, 0).rotated(vector)


func _process(delta):
	if display_time.time_left > 0:
		global_position -= endpoint * Vector2(delta, delta)		
		modulate.a -= 2 * delta
		visible = true
		floating_label.text = display_value
	else:
		queue_free()
		
	
