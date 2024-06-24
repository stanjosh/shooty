extends Node2D
@onready var point_light_2d = $PointLight2D

func _physics_process(delta):
	var offset = randf_range(-1, 2) * delta
	point_light_2d.energy = clampf(point_light_2d.energy + offset, .25, .75)
	point_light_2d.scale = clamp(point_light_2d.scale + Vector2(offset, offset), Vector2(.75, .5), Vector2(1, .5))
