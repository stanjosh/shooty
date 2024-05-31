extends CharacterBody2D

@onready var world = $".."

@export var speed = 100.0
@onready var camera = $Camera2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var target = global_position
@onready var gun = $gun
@onready var area_2d = $Area2D
@onready var reset_shots = $ResetShots

@export var health : float = 100

var attackers : Array
var input_direction : InputEvent
var combo_counter : float = 0
var is_alive : bool = true
var attacked_vector : float
var death_sprays : int = 12
var melee : int = 0
var melee_attacking : bool = false

func _physics_process(delta):

	if is_alive and not melee_attacking:
		var input_direction = Input.get_vector("left", "right", "up", "down")
		if input_direction:
			velocity = input_direction * speed
		if not input_direction:
			velocity = Vector2(0,0)
			
		if Input.is_action_pressed("shoot"):
			gun.shoot(delta)

		if Input.is_action_pressed("grenade"):
			gun.throw_grenade()
						
		if Input.is_action_just_pressed("switch fire mode"):
			gun.switch_fire_mode()
		
		if Input.is_action_just_pressed("reload"):
			gun.reload()
			
		if Input.is_action_pressed("sword"):
			melee = clampi(melee + 1, 0, 3)
			var melee_range = $sword.get_overlapping_bodies()
			if melee > 1 and melee_range.size() > 1:
				melee_attacking = true
				multiple_consecutive_slashes($sword.get_overlapping_bodies().pick_random())

				
			
		attackers = area_2d.get_overlapping_bodies()
		if attackers:
			for mob in attackers:
				health -= mob.player_damage * delta
				attacked_vector = global_position.angle_to(mob.global_position)



				
		health = clampf(health, 0, 100)

		print(melee)
		max_slides = 5
		move_and_collide(velocity * delta)
	if health <= 0:
		die(attacked_vector)

func _process(delta):
	var current_animation = ""
	if is_alive:
		if velocity.x:
			current_animation = "x_walk"
			if velocity.x > 0:
				animated_sprite_2d.flip_h = false
			elif velocity.x < 0:
				animated_sprite_2d.flip_h = true
		elif velocity.y:

			if velocity.y > 0:
				current_animation = "down_walk"
			elif velocity.y < 0:
				current_animation = "up_walk"
		elif melee_attacking:
			current_animation = "x_attack"
		else:
			current_animation = "idle"
	animated_sprite_2d.play(current_animation)

func kill_shot():
	combo_counter += 1
	reset_shots.start()

func _on_reset_shots_timeout():
	combo_counter = 0

func die(vector):

	is_alive = false

	if death_sprays:
		$CPUParticles2D.emitting = true
		const DEATH_SPRAY = preload("res://scenes/dark_spray.tscn")
		var new_spray = DEATH_SPRAY.instantiate()
		new_spray.global_position = global_position
		new_spray.rotation = randf_range(vector, 10)
		world.add_child(new_spray)
		animated_sprite_2d.play("die")
		death_sprays -= 1
		
	gun.process_mode = Node.PROCESS_MODE_DISABLED




func _on_health_pack_body_entered(body):
	health += 20
	pass # Replace with function body.



func multiple_consecutive_slashes(mob):
	
	global_position = mob.global_position

	mob.take_damage(75, global_position.angle_to(mob.global_position))
	melee = clampi(melee -1, 0, 3)
	melee_attacking = false

