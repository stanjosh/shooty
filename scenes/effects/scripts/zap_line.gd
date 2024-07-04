extends Node2D



@onready var zap_line = $ZapLine
@onready var zap = $zap



func _ready():
	zap_line.add_point(get_parent().global_position)
	zap_line.add_point(get_global_mouse_position())

func add_point(position : Vector2) -> void:
	zap_line.add_point(position)

func _process(delta):
	
	modulate.a -= 5 * delta
	if modulate.a <= 0:
		queue_free()


