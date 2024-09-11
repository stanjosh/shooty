extends Node
class_name HeadsUpDisplay

@onready var health_orb = $Bottom/HealthOrb
@onready var xp_counter: Label = $TopLeft/XPCounter

func update(element : StringName, value : float, max_value: float):
	match element:
		&"health":
			health_orb.max_health = max_value
			health_orb.health = value
		&"XP":
			pass 
			
		_:
			push_warning("%s is not a valid hud element" % element)
