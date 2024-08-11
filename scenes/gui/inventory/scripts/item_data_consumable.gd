extends ItemData
class_name ItemDataConsumable

@export var use_immediately: bool = false
@export_range(0, 100) var heal_value : int
@export_range(0, 100) var xp_amount: int

func use(target) -> void:
	if heal_value != 0:
		target.heal(heal_value)
	if xp_amount > 0:
		PlayerManager.give_xp(xp_amount)
