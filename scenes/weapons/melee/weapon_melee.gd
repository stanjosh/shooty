extends Node2D
class_name WeaponMelee

const BURNING_EFFECT = preload("res://scenes/effects/burning_effect.tscn")
const BASE_WEAPON_INFO : WeaponInfo = preload("res://scenes/weapons/ranged/gun/default_gun_info.tres")

signal melee_attack


@onready var cooldown_timer = $cooldown
@onready var effect : MeleeWeaponEffect = preload("res://scenes/weapons/melee/sword_effects.tscn").instantiate()
var weapon_info : WeaponInfo = BASE_WEAPON_INFO
var heat_level : float = 0:
	set(value):
		heat_level = value
		effect.heat_level = heat_level

func _ready():
	effect.body_entered.connect(damage)
	add_child(effect)

func _unhandled_input(event):
	if event.is_action_pressed("melee"):
		attack()

func attack() -> void:
	if not cooldown_timer.time_left:
		material.set("shader_parameter/mix_amount", heat_level * .01)
		var new_scale = Vector2(clamp(weapon_info.damage_range * .04, 0.5, 2), clamp(weapon_info.damage_area * 1.4, 1, 2))
		effect.scale = new_scale
		effect.play()
		cooldown_timer.start()
		melee_attack.emit()

func damage(body):
	if body.has_method("take_damage"):
		body.take_damage(weapon_info.damage * 10, Vector2.from_angle(global_rotation).normalized())
		apply_effects(body)
		apply_inflictions(body)

func apply_effects(body: CharacterBody2D) -> void:
	if weapon_info.speed > 100 and body.get("bleeds"):
		BloodSpray.new(Vector2.from_angle(global_rotation))

func apply_inflictions(body: CharacterBody2D) -> void:
	if heat_level > 50:
		var new_burning : Infliction = BURNING_EFFECT.instantiate()
		new_burning.period = (100 - heat_level) * .01
		new_burning.position += Vector2(-1, -8)
		body.call_deferred("add_child", new_burning)
