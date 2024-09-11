extends MarginContainer
class_name PerkSelection

signal choose_perk(perk: LevelPerk)

@export var perk : LevelPerk

func _on_button_pressed() -> void:
	choose_perk.emit(perk)
