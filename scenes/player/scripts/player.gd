extends CharacterBody2D
class_name Player

@onready var world = $".."


@export var speed = 100.0
@export var max_health : int = 100


@onready var sword = $pivot/sword
@onready var camera = $Camera2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var hitbox = $hitbox



const ACTION_LINE = preload("res://scenes/effects/action_line.tscn")

var health : int = max_health

var current_xp : int = 0
var level_up_xp : int = 100
var current_level : int = 1
var attackers : Array[Node2D]
var is_alive : bool = true
var animation_lock : bool = false
var last_known_position : Vector2
var melee_attack : bool = false
var danger_level : float


func _ready():
	XPsystem.give_xp.connect(handle_give_xp_signal)
	Hud.update_hud.emit("XPCounter", current_xp, level_up_xp)
	Powerups.give_item.connect(handle_give_item_signal)

func _physics_process(delta):
	melee_attack = false
	if is_alive:
		var input_direction : Vector2 = Input.get_vector("left", "right", "up", "down")

		if Input.is_action_just_pressed("cheat"):
			handle_give_xp_signal(10)

		if Input.is_action_pressed("sword") and not animation_lock:
			melee_attack = sword.attack(delta)

		
				
		if input_direction:
			velocity = input_direction * speed
		elif not input_direction:
			velocity = Vector2(0,0)


		max_slides = 5
		last_known_position = global_position


		handle_health(delta)
		move_and_collide(velocity * delta)
		animate(melee_attack, delta)

func get_danger():
	return danger_level

func handle_health(delta):
	if is_alive:
		attackers = hitbox.get_overlapping_bodies()
		if attackers:
			danger_level = attackers.size()
			for attacker in attackers:
				if attacker.melee_attack:
					health -= snapped(attacker.player_damage, 1)
				modulate.g = health / 100
				modulate.b = health / 100
		health = clampf(health, 0, max_health)
	if health <= 0:
		health = 0
		die()
	elif health < max_health:
		health += .7 * delta
	Hud.update_hud.emit("HealthCounter", health, max_health)

func animate(melee_attack, delta):
	if modulate.g < 1 or modulate.b < 1:
		modulate.g += 2 * delta
		modulate.b += 2 * delta

	$pivot/PlayerGlow.energy = 1 if melee_attack else clampf($pivot/PlayerGlow.energy - 6 * delta, 0, 4)
	if not is_alive:
		animated_sprite_2d.play("die")
		animation_lock = true

	if not animation_lock:
		if melee_attack:
			animation_lock = true
		var current_animation = ""

		var pivot = snapped(position.angle_to_point($pivot/angle.global_position), 1)



		if pivot < 0 and pivot > -3 :
			animated_sprite_2d.flip_h = true if pivot == -2 or pivot == -3 else false
			if melee_attack:
				current_animation = "up_attack"
			elif abs(velocity):
				current_animation = "up_walk"
			else:
				current_animation = "up_idle"

					
		elif pivot > -1 and pivot < 1:
			animated_sprite_2d.flip_h = false
			if melee_attack:
				current_animation = "x_attack"
			elif abs(velocity):
				current_animation = "x_walk"
			else:
				current_animation = "x_idle"
		
		elif pivot > 0 and pivot < 3:
			animated_sprite_2d.flip_h = false if pivot == 2 or pivot == 3 else true
			if melee_attack:
				current_animation = "down_attack"
			elif abs(velocity):
				current_animation = "down_walk"
			else:
				current_animation = "down_idle"
		
		else:
			animated_sprite_2d.flip_h = true
			if melee_attack:
				current_animation = "x_attack"	
			elif abs(velocity):
				current_animation = "x_walk"
			else:
				current_animation = "x_idle"

		
		animated_sprite_2d.play(current_animation)

		
func die():
	$pivot.process_mode = Node.PROCESS_MODE_DISABLED
	is_alive = false
	$DeathParticles.emitting = true
	for i in 12:

		const DEATH_SPRAY = preload("res://scenes/effects/dark_spray.tscn")
		var new_spray = DEATH_SPRAY.instantiate()
		new_spray.global_position = global_position
		new_spray.rotation = randf_range(0, 4)
		world.add_child(new_spray)
		

		


		

func level_up():
	current_xp = 0
	current_level += 1
	apply_level_changes(current_level)
	level_up_xp = level_up_xp + (current_level * 1.3)
	print("ding ", current_level)

var level_changes : Dictionary = {
		2 : {
			"max_health" : 2
		},
		3 : {
			"max_health" : 3,
			"speed" : 2
		},
		4 : {
			"max_health" : 4
		},
		5 : {
			"max_health" : 5
		},
		6 : {
			"max_health" : 6
		},
	}



func apply_level_changes(level):
	print("applying level changes")
	for level_reward in level_changes[level]:
			set(level_reward, get(level_reward) + level_changes[level][level_reward])
			print(level_changes[level][level_reward])



func _on_animated_sprite_2d_animation_finished():
	animation_lock = false

func handle_give_item_signal(item: PackedScene):
	var real_item = item.instantiate()
	print(item, " item received")
	if real_item is Weapon:

		$pivot.add_child(real_item)

func handle_give_xp_signal(value):
	current_xp += value
	if current_xp >= level_up_xp:
		level_up()
	Hud.update_hud.emit("XPCounter", current_xp, level_up_xp)
