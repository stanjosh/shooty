extends CharacterBody2D

@onready var world = $".."


@export var speed = 100.0
@export var max_health : float = 100

@onready var gun = $pivot/gun
@onready var sword = $pivot/sword
@onready var mine_launcher = $pivot/mine_launcher
@onready var camera = $Camera2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var hitbox = $hitbox


const ACTION_LINE = preload("res://scenes/effects/action_line.tscn")

var health : float = max_health


var attackers : Array[Node2D]
var combo_counter : int = 0
var is_alive : bool = true
var attacked_vector : float
var death_sprays : int = 12
var animation_lock : bool = false
var last_known_position : Vector2
var melee_attack : bool = false

func _physics_process(delta):
	melee_attack = false
	if is_alive:
		var input_direction : Vector2 = Input.get_vector("left", "right", "up", "down")
			
		if Input.is_action_pressed("shoot"):
			gun.shoot(delta)

		if Input.is_action_pressed("grenade"):
			mine_launcher.throw_grenade()
						
		if Input.is_action_just_pressed("switch fire mode"):
			gun.switch_fire_mode()
		
		if Input.is_action_just_pressed("reload"):
			gun.reload()
		
		if Input.is_action_pressed("sword") and not animation_lock:
			melee_attack = true
			sword.attack(delta)
		
				
		if input_direction:
			velocity = input_direction * speed
		elif not input_direction:
			velocity = Vector2(0,0)


		attackers = hitbox.get_overlapping_bodies()
		if attackers:
			for attacker in attackers:
				if attacker.melee_attack:
					health -= attacker.player_damage * delta
					attacked_vector = global_position.angle_to(attacker.global_position)
				modulate.g = health / 100
				modulate.b = health / 100



		max_slides = 5
		last_known_position = global_position


		handle_health(delta)
		move_and_collide(velocity * delta)
		animate(melee_attack, delta)


func handle_health(delta):
	health = clampf(health, 0, 100)
	if health <= 0:
		die(attacked_vector)
	elif health < max_health:
		health += .7 * delta

func animate(melee_attack, delta):
	if modulate.g < 1 or modulate.b < 1:
		modulate.g += 2 * delta
		modulate.b += 2 * delta

	$pivot/PlayerGlow.energy = 1 if melee_attack else clampf($pivot/PlayerGlow.energy - 6 * delta, 0, 4)
	
	

	if not animation_lock:
		animation_lock = true if melee_attack else false
		gun.visible = false if melee_attack else true
		var current_animation = ""
		var mouse = get_local_mouse_position()

		



		if abs(velocity.x) > abs(velocity.y):
			animated_sprite_2d.flip_h = false if mouse.x > global_position.x else true
			current_animation = "x_walk" if not melee_attack else "x_attack"
		elif mouse.y > global_position.y:
			if velocity.y > 0:
				animated_sprite_2d.flip_h = true
				current_animation = "down_walk" if not melee_attack else "down_attack"
			else:
				current_animation = "down_idle" if not melee_attack else "down_attack"
		elif mouse.y < global_position.y:
			if velocity.y < 0:
				current_animation = "up_walk" if not melee_attack else "up_attack"
			else:
				current_animation = "up_idle" if not melee_attack else "up_attack"
		else:
			current_animation = "down_idle" if not melee_attack else "down_attack"


		
		animated_sprite_2d.play(current_animation)

		
func die(vector):

	is_alive = false

	if death_sprays:
		$CPUParticles2D.emitting = true
		const DEATH_SPRAY = preload("res://scenes/effects/dark_spray.tscn")
		var new_spray = DEATH_SPRAY.instantiate()
		new_spray.global_position = global_position
		new_spray.rotation = randf_range(vector, 10)
		world.add_child(new_spray)
		animated_sprite_2d.play("die")
		death_sprays -= 1
		
	gun.process_mode = Node.PROCESS_MODE_DISABLED

		

func kill_shot():
	combo_counter += 1
	$ResetShots.start()


func _on_health_pack_body_entered(_body):
	health += 20

func _on_reset_shots_timeout():
	combo_counter = 0

func _on_animated_sprite_2d_animation_finished():
	animation_lock = false
