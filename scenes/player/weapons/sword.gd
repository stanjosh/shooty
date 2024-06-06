extends Node2D

signal AttackFinished

@onready var player = $"../.."
@onready var attack_range = $melee_range
@onready var cooldown = $cooldown
var melee_hits : int = 10
var speed : float = 40

func attack(delta):
	if not cooldown.time_left:
		player.animate(true, delta)
		[$blade_1, $blade_2, $blade_3].pick_random().play()
		var mobs : Array = attack_range.get_overlapping_bodies()
		if mobs:
			for body in mobs:
				if body is Grenade and body.delay:
					body.apply_force(global_position.direction_to(body.global_position) * speed * 2 * global_position.distance_to(body.global_position) / 3)
				elif body.has_method("take_damage"):
					body.take_damage(randi_range(20, 30), global_position.angle_to_point(body.global_position))
		

		cooldown.start()
	AttackFinished.emit()
