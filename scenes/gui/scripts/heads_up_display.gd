extends Node
class_name HeadsUpDisplay

@onready var health_orb = $Bottom/HealthOrb
@onready var overheat_meter = $Bottom/OverheatMeter

func _ready():
	UIManager.update_hud.connect(on_hud_update)

func on_hud_update(element : StringName, value : float, max_value: float):
	match element:
		&"health":
			health_orb.max_health = max_value
			health_orb.health = value
		&"heat":
			overheat_meter.max_heat = max_value
			overheat_meter.current_heat = value
		&"mines":
			pass
		&"xp":
			pass
		_:
			print("%s is not a valid hud element" % element)
