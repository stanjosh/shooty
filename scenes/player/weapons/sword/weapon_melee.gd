extends Node2D
class_name MeleeWeaponNode


@onready var hitbox = $hitbox
@onready var cooldown_timer = $cooldown
var hold_time : float = 0
@onready var slash : CPUParticles2D = $hitbox/CPUParticles2D
@export_range(1, 2) var base_melee_range : float = 1
@export_range(1, 2) var base_melee_area : float = 1
@export_range(0.2, 1) var base_cooldown : float = 1
@export var base_knockback : float = 20
@export var base_damage : int = 20

@export var speed : float = 40

var melee_range : float = 0 :
	get:
		return base_melee_range + (melee_range * .15)

var melee_area : float = 0 :
	get:
		return base_melee_area + (melee_area * .15)
		
var cooldown : float = 0 :
	get:
		return base_cooldown - (cooldown * .025)

var damage : float = 0 :
	get:
		return base_damage + (damage * 5)
		
var knockback : float = 0 :
	get:
		return base_knockback + (knockback * 10)

var status : Dictionary

var pretty_names := {
		"melee_range" : "sword range",
		"melee_area" : "sword area",
		"cooldown" : "sword cooldown",
		"damage" : "sword damage",
		"knockback" : "sword knockback"
	}

func _ready():
	cooldown_timer.wait_time = cooldown



func attack() -> bool:
	if not cooldown_timer.time_left:
		hitbox.scale = Vector2(melee_range, melee_area)
		slash.emitting = true
		[$blade_1, $blade_2, $blade_3].pick_random().play()
		var mobs : Array = hitbox.get_overlapping_bodies()
		if mobs:
			for body in mobs:
				if body is Mine and body.delay:
					body.apply_force(global_position.direction_to(body.global_position) * speed * global_position.distance_to(body.global_position) / 3)
				elif body.has_method("take_damage"):
					body.take_damage(damage, body.global_position.direction_to(global_position).normalized(), knockback)
					if body.get("bleeds"):
						const DARK_SPRAY = preload("res://scenes/effects/dark_spray.tscn")
						var new_spray = DARK_SPRAY.instantiate()
						new_spray.rotation = global_rotation
						new_spray.global_position = body.global_position
						new_spray.scale = scale
						MapManager.current_map.call_deferred("add_child", new_spray)
		cooldown_timer.start()
		return true
	else:
		return false

