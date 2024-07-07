extends Weapon
class_name Sword

@onready var hitbox = $hitbox
@onready var cooldown_timer = $cooldown
@onready var slash : CPUParticles2D = $hitbox/CPUParticles2D
@export_range(1, 2) var base_melee_range : float = 1
@export_range(1, 2) var base_melee_area : float = 1
@export_range(0.2, 1) var base_cooldown : float = 1
@export var base_knockback : float = 20
@export var base_damage : int = 20

@export var speed : float = 40

var melee_range : float = 0 :
	get:
		return base_melee_range + (melee_range * .15)

var melee_area : float = 0 :
	get:
		return base_melee_area + (melee_area * .15)
		
var cooldown : float = 0 :
	get:
		return base_cooldown - cooldown * .25

var damage : float = 0 :
	get:
		return damage + base_damage
		
var knockback : float = 0 :
	get:
		return knockback + base_knockback

var status : Dictionary

func _ready():
	for inventory_data in PlayerManager.player.equip_inventory_datas:
		inventory_data.connect("inventory_updated", equip_items)
	cooldown_timer.wait_time = cooldown
	for stat in stat_names.values():
		update_status_panel(stat)


func attack() -> bool:
	if not cooldown_timer.time_left:
		hitbox.scale = Vector2(melee_range, melee_area)
		slash.emitting = true
		[$blade_1, $blade_2, $blade_3].pick_random().play()
		var mobs : Array = hitbox.get_overlapping_bodies()
		if mobs:
			for body in mobs:
				if body is Mine and body.delay:
					body.apply_force(global_position.direction_to(body.global_position) * speed * global_position.distance_to(body.global_position) / 3)
				elif body.has_method("take_damage"):
					body.take_damage(damage, body.global_position.direction_to(global_position).normalized(), knockback)
		cooldown_timer.start()
		return true
	else:
		return false

var stat_names = {
	EquipStat.StatName.AREA : "melee_area",
	EquipStat.StatName.ACCURACY : "melee_range",
	EquipStat.StatName.COOLDOWN : "cooldown",
	EquipStat.StatName.CAPACITY : "damage",
	EquipStat.StatName.SPECIAL : "knockback"
}


func update_status():

	for item in status.keys():
		UIManager.update_stats.emit(item, status[item])

var current_stat_upgrades : Dictionary

func equip_items(_inventory_data: InventoryDataEquip):
	if _inventory_data.upgrade_target == InventoryDataEquip.UpgradeTarget.SWORD:
		current_stat_upgrades.clear()
		
		current_stat_upgrades = _inventory_data.consolidated()
		print(current_stat_upgrades)
		for stat_name in stat_names:
			var value = current_stat_upgrades[stat_name] if current_stat_upgrades.has(stat_name) else 0
			stat_name = stat_names[stat_name]
			set(stat_name, value)
			update_status_panel(stat_name)

func update_status_panel(stat_name: String):
	var pretty_names := {
		"melee_range" : "sword range",
		"melee_area" : "sword area",
		"cooldown" : "sword cooldown",
		"damage" : "sword damage",
		"knockback" : "sword knockback"
	}
	UIManager.update_stats.emit(pretty_names[stat_name], get(stat_name))
