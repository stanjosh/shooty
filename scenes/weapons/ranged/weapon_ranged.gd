extends Node2D
class_name Weapon

const BULLET = preload("res://scenes/weapons/ranged/gun/bounce_bullet.tscn")

@onready var ordinance_origin = $WeaponSprite/OrdinanceOrigin
@onready var point_light_2d : PointLight2D = $WeaponSprite/PointLight2D
@onready var progress_bar : ProgressBar = $WeaponSprite/ProgressBar
@onready var weapon_sprite : Sprite2D = $WeaponSprite
@onready var eject_particles = $EjectParticles



const BASE_WEAPON_INFO : WeaponInfo = preload("res://scenes/weapons/ranged/gun/default_gun_info.tres")


@export var weapon_info : WeaponInfo = BASE_WEAPON_INFO
var shot_time : float = 0



var heat_capacity : float = 100.0
var heat_level : float = 0 :
	set(value):
		heat_level = clampf(value, 0, heat_capacity)
		point_light_2d.energy = lerpf(0, 1, heat_level * .05)
		var scale_offset = lerpf(0, 0.5, heat_level * .02)
		point_light_2d.scale = Vector2(scale_offset, scale_offset)
		progress_bar.value = clampf(heat_level , 0, heat_capacity)
var charge_level : float = 0
var original_pos
var original_light_energy 

enum WeaponState {
	COOLING,
	FIRING,
	CHARGING,
	OVERHEATED
}

var state : WeaponState :
	set(value):
		state = value
		$SteamParticles.emitting = false
		$SteamParticles2.emitting = false

func _ready():
	original_pos = weapon_sprite.position

func _physics_process(delta):
	var pivot = wrapi(snapped(global_rotation, PI/4) / (PI/4), 0, 8)
	weapon_sprite.flip_v = true if  pivot in [3, 4, 5] else false
	weapon_sprite.z_index = -1 if pivot == 6 else 4
	var fire_anim = get_tree().create_tween()
	match state:
		WeaponState.FIRING:
			if shot_time <= 0:
				fire()
			if heat_level >= heat_capacity:
				$OverheatHiss.play()
				PlayerManager.player_camera.shake(20, 4, 1.8)
				state = WeaponState.OVERHEATED
			cool_off(16 * delta)
			fire_anim.tween_property(weapon_sprite, "position:x", original_pos.x - 2, .02).set_trans(Tween.TRANS_ELASTIC)
			if Input.is_action_pressed("shoot"):
				state = WeaponState.CHARGING
			else:
				state = WeaponState.COOLING
		WeaponState.CHARGING:
			charge(delta)
			if !Input.is_action_pressed("shoot"):
				state = WeaponState.FIRING
		WeaponState.COOLING:
			cool_off(50 * delta)
			if Input.is_action_just_pressed("shoot"):
				state = WeaponState.FIRING
		WeaponState.OVERHEATED:
			overheat()
			cool_off(24 * delta)
			if heat_level / heat_capacity < .6:
				state = WeaponState.COOLING
	fire_anim.tween_property(weapon_sprite, "position:x", original_pos.x, .2).set_trans(Tween.TRANS_LINEAR)
	shot_time -=  delta * 100 + weapon_info.fire_rate


func overheat():
	$SteamParticles.emitting = true
	$SteamParticles2.emitting = true

func cool_off(delta):
	if heat_level >= 1:
		heat_level -= delta
	else:
		heat_level = 0

func fire():
	eject_particles.emitting = true
	for n in weapon_info.multishot:
		var new_bullet = BULLET.instantiate()
		new_bullet.weapon_info = weapon_info
		new_bullet.added_damage = charge_level
		print(charge_level)
		new_bullet.scale += Vector2.ONE * charge_level * 0.3
		charge_level = 0
		new_bullet.global_position = ordinance_origin.global_position
		new_bullet.global_rotation_degrees = global_rotation_degrees + randfn(0, weapon_info.damage_area / 100)
		MapManager.current_map.add_child(new_bullet)
		heat_level += weapon_info.heat_generated
	shot_time = 100
	PlayerManager.player_camera.shake(10, heat_level * .125, 4, Vector2.from_angle(global_rotation))

func charge(delta):
	heat_level += weapon_info.heat_generated * 5 * delta
	charge_level = heat_level * .05
	pass
