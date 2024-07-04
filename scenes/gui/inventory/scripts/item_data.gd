extends Resource
class_name ItemData


@export var name : String = ""
@export_multiline var description : String = ""
@export var stackable : bool = false
@export var texture : Texture2D
@export var drop_rarity: float

func use(target) -> void:
	if target.has_method("heal"):
		target.heal(20)
	else:
		return
