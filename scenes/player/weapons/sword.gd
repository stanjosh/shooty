extends Node2D

@onready var hitbox = $hitbox
@onready var cooldown_time = $cooldown
@export_range(1, 2) var melee_range : float = 1
@export var speed : float = 40
@export_range(0.2, 1) var cooldown : float = 1


func _ready():
	cooldown_time.wait_time = cooldown

func _process(delta):
	if $hitbox/SlashEffect.modulate.a > 0:
		$hitbox/SlashEffect.modulate.a -= 2 * delta



func attack(delta):
	if not cooldown_time.time_left:
		hitbox.scale *= melee_range
		$hitbox/SlashEffect.modulate.a = 1
		[$blade_1, $blade_2, $blade_3].pick_random().play()
		var mobs : Array = hitbox.get_overlapping_bodies()
		if mobs:
			for body in mobs:
				if body is Grenade and body.delay:
					body.apply_force(global_position.direction_to(body.global_position) * speed * 2 * global_position.distance_to(body.global_position) / 3)
				elif body.has_method("take_damage"):
					body.take_damage(randi_range(20, 30), global_position.angle_to_point(body.global_position))
		cooldown_time.start()
		return true
	else:
		return false
