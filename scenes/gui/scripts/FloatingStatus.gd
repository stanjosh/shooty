extends Control

@onready var floating_label = $FloatingLabel
@onready var display_time = $display_time

var display_value : String
var value
var endpoint : Vector2
var vector: float

func _ready():
	if value is int and value > 3:
		value = "%s" % value
	if value is String:
		display_value = value
	endpoint = Vector2( -12, 0).rotated(vector) if vector else Vector2( -12, 0)

func _process(delta):
	if display_time.time_left > 0:
		global_position -= endpoint * Vector2(delta, delta)		
		modulate.a = 255 * display_time.time_left
		visible = true
		floating_label.text = display_value
	else:
		queue_free()
		
	
