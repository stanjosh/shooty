extends CharacterBody2D

@onready var world = $".."


@export var speed = 100.0
@onready var camera = $Camera2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var target = global_position
@onready var gun = $gun
@onready var area_2d = $Area2D
@onready var reset_shots = $ResetShots
const ACTION_LINE = preload("res://scenes/effects/action_line.tscn")
@export var health : float = 100

var attackers : Array
var combo_counter : float = 0
var is_alive : bool = true
var attacked_vector : float
var death_sprays : int = 12
var animation_lock : bool = false
var melee_cooldown : float = 1
var melee_hits : int = 10
var last_known_position : Vector2

func _physics_process(delta):
	modulate.g = health / 100
	modulate.b = health / 100

	
	var mobs : Array = $gun/sword.get_overlapping_bodies()
	
	mobs.sort_custom(
		func(mob, mob2):
			if mob is Grenade:
				return mob
			elif mob.global_position.distance_to(global_position) < mob2.global_position.distance_to(global_position): 
				return mob
			)
	var target_mob = mobs.pop_back()	

	
	$PlayerGlow.energy = clampf($PlayerGlow.energy - 3 * delta, 0, 4)
	var melee_attack : bool
	if is_alive:

		var input_direction : Vector2 = Input.get_vector("left", "right", "up", "down")
		if not input_direction:
			velocity = Vector2(0,0)
		
		if Input.is_action_pressed("sword") and melee_cooldown >= 1:

			if target_mob:
				melee_cooldown -= 1
				melee_attack = true
				[$blade_1, $blade_2, $blade_3].pick_random().play()
				
				var damage = randi_range(30, 60)
				velocity = global_position.direction_to(target_mob.global_position) * speed * damage
				if target_mob is Grenade and target_mob.delay:
					target_mob.apply_force(velocity)
				target_mob.take_damage(damage, global_position.angle_to_point(target_mob.global_position))
				$PlayerGlow.energy = 2
			if mobs:
				for body in mobs:
					body.take_damage(randi_range(20, 30), global_position.angle_to_point(body.global_position))
			
		elif input_direction:
			velocity = input_direction * speed
		animate(melee_attack, delta)


		
			
		



			
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
			for attacker in attackers:
				if attacker.melee_attack:
					health -= attacker.player_damage * delta
					attacked_vector = global_position.angle_to(attacker.global_position)
					sprite_flash()


				
		
		
		

		health = clampf(health, 0, 100)

		max_slides = 5

		last_known_position = global_position
		move_and_collide(velocity * delta)
	if melee_attack:
		var line = ACTION_LINE.instantiate()
		line.last_position = last_known_position
		line.first_position = global_position
		world.add_child(line)
	if melee_cooldown <= 1:
		melee_cooldown += (world.danger_factor + 2) * delta
	
	if health <= 0:
		die(attacked_vector)
	else:
		health += .7 * delta
		
func sprite_flash() -> void: 
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.DARK_RED, 0.05)

	tween.tween_property(self, "modulate", Color.WHITE, 0.05)

	tween.tween_property(self, "modulate", Color.DARK_RED, 0.05)

	tween.tween_property(self, "modulate", Color.WHITE, 0.05)
	
	
func animate(melee_attack, _delta):

	if not animation_lock:
		if melee_attack:
			animation_lock = true
		var current_animation = ""
		if velocity.x:
			current_animation = "x_attack" if melee_attack else "x_walk"
			if velocity.x > 0:
				animated_sprite_2d.flip_h = false
			elif velocity.x < 0:
				animated_sprite_2d.flip_h = true
		elif velocity.y:
			if velocity.y > 0:
				current_animation = "down_attack" if melee_attack else "down_walk"
			elif velocity.y < 0:
				current_animation = "up_attack" if melee_attack else "up_walk"
		else:
			current_animation = "x_attack" if melee_attack else "idle"

		animated_sprite_2d.play(current_animation)



func _on_reset_shots_timeout():
	combo_counter = 0

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
	reset_shots.start()


func _on_health_pack_body_entered(_body):
	health += 20


func _on_animated_sprite_2d_animation_finished():
	animation_lock = false
	pass # Replace with function body.