extends Weapon
class_name WeaponRanged

@onready var weapon_sprite : Sprite2D = $Gun
@onready var projectile_origin : Node2D = $Barrel

var heat_level : float = 0 :
	set(value):
		heat_level = clampf(value, 0, heat_capacity)
		$Gun/PointLight2D.energy = inverse_lerp(heat_capacity, heat_level, .3)
		UIManager.update_hud.emit("heat", value, heat_capacity)


var original_pos
var original_light_energy 

enum WeaponState {
	COOLING,
	FIRING,
	OVERHEATED
}

var state : WeaponState :
	set(value):
		state = value
		$SteamParticles.emitting = false
		$SteamParticles2.emitting = false

func _ready():
	UIManager.update_hud.emit("heat", heat_level, 100)
	original_pos = weapon_sprite.position
	weapon_sprite.texture = weapon_info.equip_texture

func _unhandled_input(event):
	
	if event.is_action_pressed("shoot"):
		if not state == WeaponState.OVERHEATED:
			state = WeaponState.FIRING
	elif event.is_action_released("shoot"):
		if not state == WeaponState.OVERHEATED:
			state = WeaponState.COOLING

func _physics_process(delta):
	var pivot = wrapi(snapped(global_rotation, PI/4) / (PI/4), 0, 8)
	weapon_sprite.flip_v = true if  pivot in [3, 4, 5] else false
	weapon_sprite.z_index = -1 if pivot == 6 else 4
	var fire_anim = get_tree().create_tween()
	match state:
		WeaponState.FIRING:
			shoot()
			if heat_level >= heat_capacity:
				$OverheatHiss.play()
				state = WeaponState.OVERHEATED
			fire_anim.tween_property(weapon_sprite, "position:x", clampi(original_pos.x - 4, 0, original_pos.x - 4), .08).set_trans(Tween.TRANS_ELASTIC)
		WeaponState.COOLING:
			cool_off(delta * 2)
		WeaponState.OVERHEATED:
			overheat(delta)
			if heat_level / heat_capacity < .6:
				state = WeaponState.COOLING
	fire_anim.tween_property(weapon_sprite, "position:x", original_pos.x, .05).set_trans(Tween.TRANS_LINEAR)
	cool_off(delta)


func overheat(delta):
	$SteamParticles.lifetime = heat_capacity * delta
	$SteamParticles2.lifetime = heat_capacity * delta
	$SteamParticles.emitting = true
	$SteamParticles2.emitting = true


func cool_off(delta):
	if !is_zero_approx(heat_level):
		heat_level = lerp(heat_level, 0.0, cooldown * delta)
	else:
		heat_level = 0


func shoot():
	pass


