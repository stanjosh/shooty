extends Weapon
class_name Gun


@onready var gun = $Gun

@export var base_fire_rate : float = 24
@export var base_accuracy : float = 85
@export var base_pellets : int = 1
@export var base_cooldown : float = 1
@export var base_heat_capacity : float = 100
@export var projectile : Projectile

var fire_rate : float
var accuracy : float
var pellets : int
var cooldown : float
var heat_capactity : float

var item_name : String = "Gun"
var overheated : bool = false
var heat_capacity : float = 100
var heat_level : float = 0
var shot_time : int = 0
var firing : bool = false
var original_pos
var original_light_energy 
var overheat_sound_played: bool = false
var stat_mods : Array[UpgradeDef]
var status : Dictionary

func _ready():
	fire_rate = base_fire_rate
	accuracy = base_accuracy
	pellets = base_pellets
	cooldown = base_cooldown
	heat_capacity = base_heat_capacity
	
	PlayerManager.player.equip_inventory_data.connect("inventory_updated", equip_items)
	Hud.update_hud.emit(Hud.Element.HEAT, heat_level, 100)
	original_pos = gun.position
	original_light_energy = $PointLight2D.energy
	$PointLight2D.energy = 0

func _unhandled_input(event):
	
	if event.is_action_pressed("shoot"):
		firing = true
	elif event.is_action_released("shoot"):
		firing = false

func _physics_process(delta):
	var facing_angle = wrapi(floor(get_angle_to(get_parent().position)), 0, 8)
	gun.flip_v = true if  facing_angle in range(0, 5) else false
	gun.z_index = -1 if facing_angle == 7 else 4

	$PointLight2D.energy = clampf(float(heat_level) / float(heat_capacity) * 5, 0, 5)

	if not overheated:
		overheat_sound_played = false
		$SteamParticles.emitting = false
		$SteamParticles2.emitting = false
		if firing:
			$EjectParticles.emitting = true
			shoot()
		else:
			$EjectParticles.emitting = false
		if heat_level < heat_capacity * .6:
			heat_level = clampf(heat_level - (8 * cooldown * delta), 0, heat_capacity)
			shot_time -=  delta * 100 + fire_rate
			update_hud()
		elif heat_level < heat_capacity:
			heat_level = clampf(heat_level - (16 * cooldown * delta), 0, heat_capacity)
			shot_time -=  delta * 100 + fire_rate
			update_hud()
		else:
			overheated = true

	else:
		if not overheat_sound_played:
			$OverheatHiss.play()
			$SteamParticles.lifetime = cooldown
			$SteamParticles2.lifetime = cooldown
			$SteamParticles.emitting = true
			$SteamParticles2.emitting = true
			overheat_sound_played = true

		$EjectParticles.emitting = false
		heat_level = clampf(heat_level - (2 * cooldown * delta), 0, heat_capacity)
		shot_time -=  delta * 100 + fire_rate
		update_hud()


func update_hud():
	Hud.update_hud.emit(Hud.Element.HEAT, heat_level, heat_capacity)

func shoot():

	if shot_time <= 0:
		for n in pellets:
			heat_level +=  projectile.heat_generated
			update_hud()
			var new_bullet = projectile.get_scene()
			new_bullet.global_position = to_global(position)
			var accuracy_calc = 1 - (accuracy / 100)
			new_bullet.global_rotation = global_rotation + randf_range(-accuracy_calc, accuracy_calc)
			add_child(new_bullet)
			if n == 0:
				shot_time = 100
				$GunFire.play()
		var fire_anim = get_tree().create_tween()
		$PointLight2D.energy = clampf($PointLight2D.energy + .3, 0, 5)
		fire_anim.tween_property(gun, "position:x", clamp(gun.position.x - 2, 0, -4), .3).set_trans(Tween.TRANS_ELASTIC)
		fire_anim.tween_property(gun, "position:x", original_pos.x, .3).set_trans(Tween.TRANS_LINEAR)
		
		$Overheat.wait_time = cooldown
		$Overheat.start()
		




func _on_overheat_timeout():
	overheated = false



func update_status():
	fire_rate = base_fire_rate
	accuracy = base_accuracy
	pellets = base_pellets
	cooldown = base_cooldown
	heat_capacity = base_heat_capacity
	

	for item in stat_mods:
		set(item.upgrade_stat, get(item.upgrade_stat) + item.upgrade_value)
	status = {
		"fire_rate" : fire_rate,
		"accuracy" : accuracy,
		"pellets" : pellets,
		"cooldown" : cooldown,
		"heat_capacity" : heat_capacity
	}
	for item in status.keys():
		Hud.stats[item] = status[item]

func equip_items(inventory_data):
	stat_mods.clear()
	for slot_data in inventory_data.slot_datas:
		if slot_data and slot_data.item_data and slot_data.item_data.upgrades:
			for item in slot_data.item_data.upgrades:
				if item.upgrade_target == "gun":
					stat_mods.push_front(item)
	update_status()
