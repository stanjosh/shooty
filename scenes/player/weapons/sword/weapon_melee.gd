extends Node2D
class_name MeleeWeaponNode


@onready var hitbox : Area2D = $hitbox
@onready var cooldown_timer = $cooldown
var ordinance : ItemDataEquippable

var effect : Node2D

func set_equip(_ordinance:  ItemDataEquippable):
	print(ordinance)
	ordinance = _ordinance
	effect = ordinance.get_scene()
	add_child(effect)
	cooldown_timer.wait_time = ordinance.cooldown

func attack() -> bool:

	if not cooldown_timer.time_left:
		effect.play()
		
		hitbox.scale = Vector2(ordinance.melee_range, ordinance.area)

		var mobs : Array = hitbox.get_overlapping_bodies()
		if mobs:
			for body in mobs:
				if body.has_method("take_damage"):
					var _angle = body.global_position.direction_to(global_position).normalized()
					body.take_damage(ordinance.damage, _angle, ordinance.knockback)
					if ordinance.cutting and body.get("bleeds"):
						BloodSpray.new(body, -_angle)
		cooldown_timer.start()
		return true
	else:
		return false

