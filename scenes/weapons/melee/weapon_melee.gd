extends Weapon
class_name WeaponMelee

signal melee_attack

@onready var hitbox : Area2D = $hitbox
@onready var cooldown_timer = $cooldown

@onready var effect : MeleeWeaponEffect = weapon_info.weapon_effect.instantiate()

func _unhandled_input(event):
	if event.is_action_pressed("melee"):
		attack()

func attack() -> void:

	if not cooldown_timer.time_left:
		effect.play()
		hitbox.scale = Vector2(weapon_range, area)
		var mobs : Array = hitbox.get_overlapping_bodies()
		if mobs:
			for body in mobs:
				if body.has_method("take_damage"):
					var _angle = body.global_position.direction_to(global_position).normalized()
					body.take_damage(damage, _angle, knockback)
					if weapon_info.cutting and body.get("bleeds"):
						BloodSpray.new(body, -_angle)
		cooldown_timer.start()
		melee_attack.emit()

