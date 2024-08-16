@tool
extends Line2D
class_name LightningBolt

var opacity : float = 1
var lifetime : float = 3

func _init(points: Array = []) -> void:
	points = points
	

func _ready() -> void:
	closed = false

func _process(delta: float) -> void:
	lifetime -= delta
	opacity -= randf() * lifetime * delta
	width *= opacity
	modulate.a = opacity
	if lifetime < 0:
		queue_free()
