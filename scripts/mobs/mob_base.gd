extends CharacterBody2D
class_name Mob

const DAMAGE_NUMBER = preload ("res://scenes/effects/FloatingStatus.tscn")
@onready var animated_sprite_2d = $AnimatedSprite2D

@onready var world = $"../"
@onready var player = $"../player"

var scalar : float = 1
@export var growing : bool = false
@export var player_damage = randf_range(1, 7)
@export var move_speed : float
@export var max_health : int
@export var bleeds : bool = false
@export var death_particles : bool = true
@export var flying : bool = false
var is_alive : bool = true
var melee_attack : bool = false
var health : int


func _ready():
	health = max_health
	move_speed += 4 * (1 - scalar/2)
	max_health += (10 * scalar) * (1 - scalar)
	
	if flying:
		set_collision_mask_value(3, true)
		set_collision_layer_value(3, true)
		set_collision_mask_value(7, false)
		set_collision_layer_value(7, false)
		set_collision_mask_value(6, false)
		set_collision_layer_value(6, false)
		set_collision_mask_value(2, false)
		set_collision_layer_value(2, false)
	else:
		set_collision_mask_value(3, false)
		set_collision_layer_value(3, false)
		set_collision_mask_value(7, true)
		set_collision_layer_value(7, true)
		set_collision_mask_value(2, true)
		set_collision_layer_value(2, true)
	if growing:
		scale *= Vector2(snapped(clampf(scalar / 2, 1, 2), .25), snapped(clampf(scalar / 2, 1, 2), .25))


func _physics_process(delta):
	if is_alive:
		if global_position.distance_to(player.global_position) > 750:
			queue_free()
		elif global_position.distance_to(player.global_position) < 16:
			melee_attack = true
			velocity = Vector2(0,0)
		else:
			velocity = global_position.direction_to(player.global_position) * move_speed
			melee_attack = false
		
		animate()
		move_and_collide(velocity * delta)
	else:
		$CollisionShape2D.disabled = true

func animate():
	var current_animation = "attack" if melee_attack else "idle"
	if velocity.x != 0:
		current_animation = "x_walk" if animated_sprite_2d.sprite_frames.has_animation("x_walk") else "idle"
		animated_sprite_2d.flip_h = false if velocity.x > 0 else true
	elif velocity.y > velocity.x:
		current_animation = "y_walk" if animated_sprite_2d.sprite_frames.has_animation("y_walk") else "idle"
			
			
	animated_sprite_2d.play(current_animation)

func take_damage(hit, vector):
	show_damage(hit, vector)
	if health > 0:
		health -= hit
	if health <= 0:
		is_alive = false
		die(vector)

func show_damage(hit, vector):
	var new_damage_number = DAMAGE_NUMBER.instantiate()
	new_damage_number.value = hit
	var rando_pos = snapped(randf_range(-12, 12), 6)
	new_damage_number.global_position = Vector2(global_position.x + rando_pos, global_position.y)
	new_damage_number.vector = vector
	world.call_deferred("add_child", new_damage_number)


func die(vector):
	if death_particles:
		$DeathAnimationTimer.wait_time = $CPUParticles2D.lifetime
		$CPUParticles2D.emitting = true
	if bleeds:
		const DARK_SPRAY = preload("res://scenes/effects/dark_spray.tscn")
		var new_spray = DARK_SPRAY.instantiate()
		new_spray.global_position = global_position
		new_spray.rotation = vector
		new_spray.scale = scale
		world.call_deferred("add_child", new_spray)
	$DeathAnimationTimer.start()
	$AnimatedSprite2D.play("die")

		
func _on_death_animation_timer_timeout():
	player.kill_shot()
	queue_free()
