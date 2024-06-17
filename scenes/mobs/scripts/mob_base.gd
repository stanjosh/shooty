extends CharacterBody2D
class_name Mob

const DAMAGE_NUMBER = preload ("res://scenes/effects/FloatingStatus.tscn")
@onready var animated_sprite_2d := $AnimatedSprite2D
@onready var collision_shape_2d := $CollisionShape2D



@onready var player : CharacterBody2D = get_node("/root/Game/World/player")
@onready var navigation_agent_2d : NavigationAgent2D = $NavigationAgent2D

var scalar : float = 1
@export var growing : bool = false
@export var player_damage = randf_range(1, 7)
@export var move_speed : float
@export var acceleration : float = 7
@export var max_health : int
@export var bleeds : bool = false
@export var death_particles : bool = true
@export var flying : bool = false
@export_range(20, 100) var attack_distance : int = 20
@export var xp_value : int = 0

@export var detection_area : Area2D

var is_alive : bool
var melee_attack : bool = false
var health : int
var animation_lock : bool = false

func _ready():
	if detection_area:
		is_alive = false
		detection_area.body_entered.connect(wake_up)
		
	else:
		is_alive = true
	animated_sprite_2d.connect("animation_finished", on_animation_finished)
	health = max_health
	move_speed += 4 * (1 - scalar/2)
	max_health += snapped((10 * scalar) * (1 - scalar), 1)
	
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
		set_collision_mask_value(7, true)
		set_collision_mask_value(2, true)
		set_collision_mask_value(5, true)
		set_collision_mask_value(8, true)
		
		set_collision_layer_value(7, true)
		
	if growing:
		scale *= Vector2(snapped(clampf(scalar / 2, 1, 2), .25), snapped(clampf(scalar / 2, 1, 2), .25))

		

func _physics_process(delta):
	if is_alive and not animation_lock:
		if global_position.distance_to(player.global_position) < attack_distance:
			velocity = Vector2(0,0)
			attack()
		elif not player.is_alive: 
			velocity = global_position.direction_to(player.global_position) * -move_speed
		else:
			if navigation_agent_2d and player.is_alive:
				var direction = Vector2()
				navigation_agent_2d.target_position = player.global_position
				direction = navigation_agent_2d.get_next_path_position() - global_position
				direction = direction.normalized()
				velocity = velocity.lerp(direction * move_speed, acceleration * delta)
			else:	
				velocity = global_position.direction_to(player.global_position) * move_speed
		animate()
		move_and_slide()
	elif not is_alive:
		velocity = Vector2(0,0)
		


	

func attack():
	if not animation_lock:
		player.take_damage(player_damage, global_position.angle_to_point(player.global_position))
		animated_sprite_2d.play("attack")
		animation_lock = true
		
func animate():
	if not animation_lock:
		var current_animation : String
		if velocity.x != 0:
			current_animation = "x_walk" if animated_sprite_2d.sprite_frames.has_animation("x_walk") else "idle"
			animated_sprite_2d.flip_h = false if velocity.x > 0 else true
		elif velocity.y > velocity.x:
			current_animation = "y_walk" if animated_sprite_2d.sprite_frames.has_animation("y_walk") else "idle"
		animated_sprite_2d.play(current_animation)

func take_damage(hit, vector):
	show_damage(hit, vector)
	velocity += Vector2(10 * hit, 10 * hit).rotated(vector)
	var tween: Tween = create_tween()
	tween.tween_property(animated_sprite_2d, "modulate:v", 1, 0.25).from(15)
	if health > 0:
		health -= hit
	if health <= 0:
		is_alive = false
		collision_shape_2d.disabled = true
		die(vector)

func show_damage(hit, vector):
	var new_damage_number = DAMAGE_NUMBER.instantiate()
	new_damage_number.value = hit
	var rando_pos = snapped(randf_range(-12, 12), 6)
	new_damage_number.global_position = Vector2(global_position.x + rando_pos, global_position.y)
	new_damage_number.vector = vector
	get_parent().call_deferred("add_child", new_damage_number)


func die(vector):
	var timer = Timer.new()
	
	timer.connect("timeout", _on_death_animation_timer_timeout)
	
	animated_sprite_2d.play("die")
	animation_lock = true
	XPsystem.give_xp.emit(xp_value)
	
	if death_particles:
		timer.wait_time = $CPUParticles2D.lifetime
		$CPUParticles2D.emitting = true
		timer.autostart = true
	if bleeds:
		const DARK_SPRAY = preload("res://scenes/effects/dark_spray.tscn")
		var new_spray = DARK_SPRAY.instantiate()
		new_spray.global_position = $CollisionShape2D.global_position
		new_spray.rotation = vector
		new_spray.scale = scale
		get_parent().call_deferred("add_child", new_spray)
	add_child(timer)

func wake_up(body):
	if body is Player:
		is_alive = true
		collision_shape_2d.disabled = false
		
func _on_death_animation_timer_timeout():
	queue_free()

func on_animation_finished():
	animation_lock = false
