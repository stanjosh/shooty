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

func _physics_process(delta):

	if is_alive:
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
			
		attackers = area_2d.get_overlapping_bodies()
		if attackers:
			for mob in attackers:
				health -= mob.player_damage * delta
				attacked_vector = global_position.angle_to(mob.global_position)
				


				
		health = clampf(health, 0, 100)

			
		max_slides = 5
		move_and_collide(velocity * delta)
		
	if health <= 0:
		die(attacked_vector)

func _process(delta):
	
	if is_alive:
		var current_animation = ""
		if velocity.x == 0 and velocity.y == 0 and not input_direction:
			current_animation = "idle"
		else:
			if velocity.x or input_direction:
				current_animation = "x_walk"
				if velocity.x > 1:
					animated_sprite_2d.flip_h = false
				elif velocity.x < 1:
					animated_sprite_2d.flip_h = true
			if abs(velocity.y) > abs(velocity.x):
				if velocity.y > 0:
					current_animation = "down_walk"
				elif velocity.y < 0:
					current_animation = "up_walk"
		animated_sprite_2d.play(current_animation)

func kill_shot():
	combo_counter += 1
	reset_shots.start()

func _on_reset_shots_timeout():
	combo_counter = 0

func die(vector):

	is_alive = false
	if death_sprays:
		const DEATH_SPRAY = preload("res://scenes/dark_spray.tscn")
		var new_spray = DEATH_SPRAY.instantiate()
		new_spray.global_position = global_position
		new_spray.rotation = randf_range(vector, 10)
		world.add_child(new_spray)
		animated_sprite_2d.play("die")
		death_sprays -= 1
	
	




func _on_health_pack_body_entered(body):
	health += 20
	pass # Replace with function body.
