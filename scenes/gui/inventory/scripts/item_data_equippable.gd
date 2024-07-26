extends ItemData
class_name ItemDataEquippable

enum EquipType {
	MELEE,
	RANGED,
	STREAM
}

@export var equip_type : EquipType
@export var equip_texture : Texture2D
@export var weapon_effect : PackedScene
@export var base_damage : int
@export_range(0.1, 0.9) var base_cooldown : float
@export var heat_generated : float
@export var base_fire_rate : float
@export var base_heat_capacity : float
@export var base_pellets : int
@export_range(1, 2) var base_area : float
@export_range(1, 2) var base_range : float
@export var base_knockback : float
