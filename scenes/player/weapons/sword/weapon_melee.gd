extends Node2D
class_name MeleeWeaponNode


@onready var hitbox = $hitbox
@onready var cooldown_timer = $cooldown
@onready var slash : CPUParticles2D = $hitbox/CPUParticles2D
@export var cutting : bool
@export var ordinance : EquippableMeleeWeapon

func _ready():
	cooldown_timer.wait_time = ordinance.cooldown



func attack() -> bool:
	if not cooldown_timer.time_left:
		hitbox.scale = Vector2(ordinance.melee_range, ordinance.melee_area)
		slash.emitting = true
		[$blade_1, $blade_2, $blade_3].pick_random().play()
		var mobs : Array = hitbox.get_overlapping_bodies()
		if mobs:
			for body in mobs:
				if body is Mine and body.delay:
					body.apply_force(global_position.direction_to(body.global_position) * ordinance.speed * global_position.distance_to(body.global_position) / 3)
				elif body.has_method("take_damage"):
					var _angle = body.global_position.direction_to(global_position).normalized()
					body.take_damage(ordinance.damage, _angle, ordinance.knockback)
					if cutting and body.get("bleeds"):
						BloodSpray.new(body, -_angle)
		cooldown_timer.start()
		return true
	else:
		return false

