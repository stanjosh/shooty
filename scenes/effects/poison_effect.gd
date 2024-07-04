extends Infliction


@export var damage : float = 5

func activate():
	if get_parent().has_method("take_damage"):
		get_parent().take_damage(damage, Vector2.UP, -damage)
	return super.activate()
