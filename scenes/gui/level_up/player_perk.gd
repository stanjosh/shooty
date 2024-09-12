extends LevelPerk
class_name PlayerPerk

@export var stat : String
@export var value : float

func apply_perk(target : Player) -> void:
	target.set(stat, target.get(stat) + target.get(stat) * value)
	return super.apply_perk(target)
