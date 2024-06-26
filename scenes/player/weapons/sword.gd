extends Weapon
class_name Sword

@onready var hitbox = $hitbox
@onready var cooldown_time = $cooldown
@onready var slash : CPUParticles2D = $hitbox/CPUParticles2D
@export_range(1, 2) var melee_range : float = 1
@export var speed : float = 40
@export_range(0.2, 1) var cooldown : float = 1
@export var damage : int = 20


func _ready():
	cooldown_time.wait_time = cooldown


func attack() -> bool:
	if not cooldown_time.time_left:
		hitbox.scale = Vector2(melee_range, melee_range)
		slash.emitting = true
		[$blade_1, $blade_2, $blade_3].pick_random().play()
		var mobs : Array = hitbox.get_overlapping_bodies()
		if mobs:
			for body in mobs:
				if body is Mine and body.delay:
					body.apply_force(global_position.direction_to(body.global_position) * speed * global_position.distance_to(body.global_position) / 3)
				elif body.has_method("take_damage"):
					body.take_damage(damage, PlayerManager.player.global_position.angle_to_point(body.global_position))
		cooldown_time.start()
		return true
	else:
		return false


	
