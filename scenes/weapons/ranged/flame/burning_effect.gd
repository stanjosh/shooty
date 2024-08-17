extends Infliction

@onready var spread :Area2D = $Spread

@export var damage : float = 5

func activate():
	if get_parent().has_method("take_damage"):
		get_parent().take_damage(damage, Vector2.UP, -damage)
	var spread_bodies = spread.get_overlapping_bodies().filter(func(body): return body != get_parent)
	if spread_bodies:
		for body in spread_bodies:
			body.add_child(self.duplicate())
		
	return super.activate()
