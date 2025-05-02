extends Node
class_name HeadsUpDisplay

@onready var health_orb = $Bottom/HealthOrb

func update(element : StringName, value : float, max_value: float):
	match element:
		&"health":
			health_orb.max_health = max_value
			health_orb.health = value
		&"mines":
			pass
		&"xp":
			pass
		_:
			push_warning("%s is not a valid hud element" % element)
