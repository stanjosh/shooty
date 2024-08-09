extends Node2D
class_name Weapon

const BULLET = preload("res://scenes/weapons/ranged/gun/bullet.tscn")

@onready var ordinance_origin = $WeaponSprite/OrdinanceOrigin
@onready var point_light_2d : PointLight2D = $WeaponSprite/PointLight2D
@onready var progress_bar : ProgressBar = $WeaponSprite/ProgressBar
@onready var weapon_sprite : Sprite2D = $WeaponSprite
@onready var eject_particles = $EjectParticles
@onready var inventory_data : InventoryDataEquip = InventoryDataEquip.new()

@export var base_weapon_info : WeaponInfo = preload("res://scenes/weapons/ranged/gun/default_gun_info.tres")

var weapon_info : WeaponInfo = base_weapon_info
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
	inventory_data.inventory_updated.connect(_on_change_equip)
	_on_change_equip(inventory_data)
	GUI.refresh_interface.emit(self)
	original_pos = weapon_sprite.position

func _unhandled_input(event):
	
	if not state == WeaponState.OVERHEATED:
		if event.is_action_released("shoot"):
			state = WeaponState.COOLING
		elif event.is_action_pressed("shoot"):
			state = WeaponState.FIRING
		

			

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
				state = WeaponState.OVERHEATED
			cool_off(16 * delta)
			fire_anim.tween_property(weapon_sprite, "position:x", clampi(original_pos.x - 4, 0, original_pos.x - 4), .08).set_trans(Tween.TRANS_ELASTIC)
		WeaponState.CHARGING:
			charge(delta)
		WeaponState.COOLING:
			cool_off(50 * delta)
		WeaponState.OVERHEATED:
			overheat(delta)
			cool_off(24 * delta)
			if heat_level / heat_capacity < .6:
				state = WeaponState.COOLING
	shot_time -=  delta * 100 + weapon_info.fire_rate
	fire_anim.tween_property(weapon_sprite, "position:x", original_pos.x, .05).set_trans(Tween.TRANS_LINEAR)

func overheat(delta):

	$SteamParticles.lifetime = heat_capacity * delta
	$SteamParticles2.lifetime = heat_capacity * delta
	$SteamParticles.emitting = true
	$SteamParticles2.emitting = true

func cool_off(delta):
	if heat_level >= 1:
		heat_level -= delta
	else:
		heat_level = 0

func fire():
	eject_particles.emitting = true
	for n in weapon_info.pellets:
		var new_bullet = BULLET.instantiate()
		new_bullet.weapon_info = weapon_info
		new_bullet.damage += charge_level
		charge_level = 0
		new_bullet.global_position = ordinance_origin.global_position
		new_bullet.global_rotation_degrees = global_rotation_degrees + randfn(0, weapon_info.area / 100)
		add_child(new_bullet)
		heat_level += weapon_info.heat_generated
	shot_time = 100

func charge(delta):
	heat_level += weapon_info.heat_generated * 5 * delta
	charge_level = heat_level * .05
	pass


func _on_change_equip(_inventory_data : InventoryDataEquip) -> void:
	var new_weapon_info = _inventory_data.consolidated_weapon_info()
	for property in new_weapon_info.get_property_list():
		if property["usage"] == 4102:
			weapon_info.set(property.name, new_weapon_info.get(property.name) + base_weapon_info.get(property.name))
