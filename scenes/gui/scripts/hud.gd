extends CanvasLayer

signal drop_slot_data(slot_data)

@onready var health_orb = $Bottom/HealthOrb
@onready var overheat_meter = $Bottom/OverheatMeter

@onready var XPCounter = $TopLeft/XPCounter


func _ready():
	Hud.update_hud.connect(on_hud_update)

func on_hud_update(element : Hud.Element, value : float, max_value: float):
	match element:
		Hud.Element.HEALTH:
			health_orb.max_health = max_value
			health_orb.health = value
		Hud.Element.HEAT:
			overheat_meter.max_heat = max_value
			overheat_meter.current_heat = value
		Hud.Element.MINES:
			pass
		Hud.Element.XP:
			pass
		_:
			print("%s is not a valid hud element" % element)

func _on_inventory_interface_drop_slot_data(slot_data):
	drop_slot_data.emit(slot_data)
