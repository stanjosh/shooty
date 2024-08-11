extends Node2D
class_name WeaponMelee

signal melee_attack

@onready var hitbox : Area2D = $hitbox
@onready var cooldown_timer = $cooldown
@onready var effect : MeleeWeaponEffect = preload("res://scenes/weapons/melee/sword_effects.tscn").instantiate()
const BURNING_EFFECT = preload("res://scenes/effects/burning_effect.tscn")
var heat_level : float = 0:
	set(value):
		heat_level = value
		effect.heat_level = heat_level

const BASE_WEAPON_INFO : WeaponInfo = preload("res://scenes/weapons/ranged/gun/default_gun_info.tres")

var weapon_info : WeaponInfo = BASE_WEAPON_INFO

func _ready():
	add_child(effect)

func _unhandled_input(event):
	if event.is_action_pressed("melee"):
		attack()


func attack() -> void:
	if not cooldown_timer.time_left:
		material.set("shader_parameter/mix_amount", heat_level * .01)
		effect.play()
		var new_scale = Vector2(clamp(weapon_info.shot_range * .02, 0.5, 2), clamp(weapon_info.area, 1, 2))
		hitbox.scale = new_scale
		effect.scale = new_scale
		var mobs : Array = hitbox.get_overlapping_bodies()
		if mobs:
			for body in mobs:
				if body.has_method("take_damage"):
					var _angle = body.global_position.direction_to(global_position).normalized()
					body.take_damage(weapon_info.damage, _angle, weapon_info.knockback)
					if weapon_info.cutting and body.get("bleeds"):
						BloodSpray.new(body, -_angle)
					if heat_level > 50:
						var new_burning : Infliction = BURNING_EFFECT.instantiate()
						new_burning.period = (100 - heat_level) * .01
						new_burning.position += Vector2(-1, -8)
						body.call_deferred("add_child", new_burning)
		cooldown_timer.start()
		melee_attack.emit()

