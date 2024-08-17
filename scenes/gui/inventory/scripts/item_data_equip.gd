extends ItemData
class_name ItemDataEquippable

@export var ordinance_scene : PackedScene
@export var equip_texture : Texture2D
@export var weapon_info : WeaponInfo



func get_ordinance() -> WeaponOrdinance:
	var ordinance : WeaponOrdinance = ordinance_scene.instantiate()
	ordinance.weapon_info = weapon_info
	return ordinance
