extends Resource
class_name LevelPerk

@export var rarity : float = 0
@export_multiline var description : String = "The basic perk, you should probably put some info here."
@export var tile : String = "New Perk"

func apply_perk(target) -> void:
	pass
	
func remove_perk(target) -> void:
	pass
