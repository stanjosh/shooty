extends Node2D
class_name RangedWeaponNode

@onready var weapon_sprite : Sprite2D = $Gun
@onready var projectile_origin : Node2D = $Barrel

@export var base_fire_rate : float = 3
@export var base_accuracy : float = 85
@export var base_pellets : int = 1
@export var base_cooldown : float = .25
@export var base_heat_capacity : float = 100
@export var ordinance : Ordinance



var fire_rate : float = 0 :
	get:
		return fire_rate + base_fire_rate

var accuracy : float = 0 :
	get:
		return base_accuracy + (accuracy * .5)
	
var pellets : int = 0 :
	get:
		return pellets + base_pellets

var heat_capacity : float = 0 :
	get:
		return base_heat_capacity + (heat_capacity * 5)

var cooldown : float = 0 :
	get:
		return base_cooldown + (cooldown * .125)

var item_name : String = "Gun"
var heat_level : float = 0 :
	set(value):
		heat_level = clampf(value, 0, heat_capacity)
		$Gun/PointLight2D.energy = inverse_lerp(heat_capacity, heat_level, .3)
		UIManager.update_hud.emit("heat", value, heat_capacity)

var shot_time : int = 0
var original_pos
var original_light_energy 
var overheat_sound_played: bool = false

enum GunState {
	COOLING,
	FIRING,
	OVERHEATED
}
var state : GunState :
	set(value):
		state = value
		$SteamParticles.emitting = false
		$SteamParticles2.emitting = false

func _ready():
	if ordinance.shot_type == Ordinance.Shoots.STREAM:
		projectile_origin.add_child(ordinance.get_scene())
	for inventory_data in PlayerManager.player.equip_inventory_datas:
		inventory_data.connect("inventory_updated", equip_items)
	UIManager.update_hud.emit("heat", heat_level, 100)
	original_pos = weapon_sprite.position
	for stat in stat_names.values():
		update_status_panel(stat)
		

func _unhandled_input(event):
	
	if event.is_action_pressed("shoot"):
		if not state == GunState.OVERHEATED:
			state = GunState.FIRING
	elif event.is_action_released("shoot"):
		if not state == GunState.OVERHEATED:
			state = GunState.COOLING

func _physics_process(delta):
	var pivot = wrapi(snapped(global_rotation, PI/4) / (PI/4), 0, 8)
	weapon_sprite.flip_v = true if  pivot in [3, 4, 5] else false
	weapon_sprite.z_index = -1 if pivot == 6 else 4
	if ordinance.shot_type == Ordinance.Shoots.STREAM:
		for child in projectile_origin.get_children():
			child.emitting = false
	match state:
		GunState.FIRING:
			if shot_time <= 0 and ordinance.shot_type == Ordinance.Shoots.PROJECTILE:
				shoot()
			elif ordinance.shot_type == Ordinance.Shoots.STREAM:
				for child in projectile_origin.get_children():
					child.emitting = true
					child.damage *= pellets
					child.projectile.global_rotation_degrees = global_rotation_degrees + randfn(0, accuracy / 100)
					heat_level += child.heat_generated * delta
			if heat_level >= heat_capacity:
				state = GunState.OVERHEATED
		GunState.COOLING:

			overheat_sound_played = false
			cool_off(delta * 2)
		GunState.OVERHEATED:
			if not overheat_sound_played:
				$Overheat.wait_time = heat_capacity * delta
				$Overheat.start()
				$OverheatHiss.play()
				$SteamParticles.lifetime = cooldown
				$SteamParticles2.lifetime = cooldown
				$SteamParticles.emitting = true
				$SteamParticles2.emitting = true
				overheat_sound_played = true
				
	#print(GunState.keys()[state], " | ", heat_level)
	cool_off(delta)
	shot_time -=  delta * 100 + fire_rate


func cool_off(delta):
	if !is_zero_approx(heat_level):
		heat_level = lerp(heat_level, 0.0, cooldown * delta)
	else:
		heat_level = 0


func shoot():


	for n in pellets:
		
		var new_bullet = ordinance.get_scene()
		heat_level +=  new_bullet.heat_generated
		new_bullet.global_position = to_global(projectile_origin.position)
		
		new_bullet.global_rotation_degrees = global_rotation_degrees + randfn(0, accuracy / 100)
		projectile_origin.add_child(new_bullet)
		if n == 0:
			shot_time = 100
	var fire_anim = get_tree().create_tween()
	fire_anim.tween_property(weapon_sprite, "position:x", clamp(weapon_sprite.position.x - 2, 0, -4), .3).set_trans(Tween.TRANS_ELASTIC)
	fire_anim.tween_property(weapon_sprite, "position:x", original_pos.x, .3).set_trans(Tween.TRANS_LINEAR)
		

		


var stat_names = {
	ItemDataEquip.StatName.AREA : "pellets",
	ItemDataEquip.StatName.ACCURACY : "accuracy",
	ItemDataEquip.StatName.COOLDOWN : "fire_rate",
	ItemDataEquip.StatName.CAPACITY : "heat_capacity",
	ItemDataEquip.StatName.SPECIAL : "cooldown"
}



var current_stat_upgrades : Dictionary

func equip_items(_inventory_data: InventoryDataEquip):
	if _inventory_data.upgrade_target == InventoryDataEquip.UpgradeTarget.GUN:
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
		"heat_capacity" : "Gun heat capacity",
		"accuracy" : "Gun accuracy",
		"fire_rate" : "Gun fire rate",
		"pellets" : "Gun projectiles",
		"cooldown" : "Gun cooling rate"
	}
	UIManager.update_stats.emit(pretty_names[stat_name], get(stat_name))

func _on_overheat_timeout():
	state = GunState.COOLING
