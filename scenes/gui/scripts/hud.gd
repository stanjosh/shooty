extends CanvasLayer

signal drop_slot_data(slot_data)

@onready var health_orb = $Bottom/HealthOrb
@onready var overheat_meter = $Bottom/OverheatMeter
@onready var bottom = $Bottom
@onready var XPCounter = $TopLeft/XPCounter
@onready var inventory_interface = $InventoryInterface
@onready var game_over_interface = $GameOver


func _ready():
	PlayerManager.game_over.connect(game_over)
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

func game_over():
	
	bottom.visible = false
	inventory_interface.visible = false
	game_over_interface.visible = true

func _on_inventory_interface_drop_slot_data(slot_data):
	drop_slot_data.emit(slot_data)


func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

