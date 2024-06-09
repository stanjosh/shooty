extends Node2D

@onready var hitbox = $hitbox
@onready var cooldown_time = $cooldown
@onready var slash : Line2D = $hitbox/SlashEffect
@export_range(1, 2) var melee_range : float = 1
@export var speed : float = 40
@export_range(0.2, 1) var cooldown : float = 1


func _ready():
	cooldown_time.wait_time = cooldown

func _process(delta):
	if slash.modulate.a > 0:
		slash.modulate.a -= 2 * delta
	else:
		slash.hide()



func attack(delta):
		
	if not cooldown_time.time_left:
		
		hitbox.scale *= melee_range
		slash.width_curve.set_point_offset(1, randf_range(0.25, 0.75))
		slash.show()
		slash.modulate.a = 1

		[$blade_1, $blade_2, $blade_3].pick_random().play()
		var mobs : Array = hitbox.get_overlapping_bodies()
		if mobs:
			for body in mobs:
				if body is Mine and body.delay:
					body.apply_force(global_position.direction_to(body.global_position) * speed * global_position.distance_to(body.global_position) / 3)
				elif body.has_method("take_damage"):
					body.take_damage(randi_range(20, 30), global_position.angle_to_point(body.global_position))
		cooldown_time.start()
		return true
	else:
		return false
