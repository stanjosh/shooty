extends Resource
class_name LevelPerk

@export var image : Texture2D
@export var name : String
@export_multiline var description : String
@export var rarity : float = 0
@export var perk_type : StringName = "health"



func apply_perk(target) -> void:
	call(perk_type, target)

func health(target, amount : float = 1.2) -> void:
	target.max_health *= 1.2
