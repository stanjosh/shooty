extends Control

@onready var floating_label = $FloatingLabel
@onready var display_time = $display_time

var display_value : String
var value
var endpoint : Vector2
var vector: Vector2

func _ready():
	if value is int and value > 3:
		value = "%s" % value
	if value is String:
		display_value = value
	endpoint = Vector2( -12, 0) - vector * 40
	get_tree().create_tween().tween_property(self, "modulate:a", 0, display_time.time_left).from(1)

func _process(delta):
	if display_time.time_left > 0:
		global_position -= endpoint * Vector2(delta, delta)		
		visible = true
		floating_label.text = display_value
	else:
		queue_free()
		
	
