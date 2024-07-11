extends Infliction
@onready var point_light_2d = $PointLight2D
@export var damage : float = 5

func activate():
	if get_parent().has_method("take_damage"):
		get_parent().take_damage(damage, Vector2.UP, -damage)
	return super.activate()


func _physics_process(delta):
	var offset = randf_range(-1, 2) * delta
	point_light_2d.energy = clampf(point_light_2d.energy + offset, .25, .75)
	point_light_2d.scale = clamp(point_light_2d.scale + Vector2(offset, offset), Vector2(.75, .5), Vector2(1, .5))

