extends CharacterBody2D
class_name Mob

signal player_detected

const PICKUP_ITEM = preload("res://scenes/gui/inventory/items/pickup_item.tscn")


#@onready var navigation_agent_2d := $NavigationAgent2D
@onready var cpu_particles_2d := $CPUParticles2D
@onready var hurtbox : Area2D = $Hurtbox
@onready var idle_timer : Timer = $IdleTimer
@onready var cry_sound : AudioStreamPlayer2D = $CrySound
@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox := $Hitbox
@onready var detection_area : Area2D = $DetectionArea
@onready var hurtbox_anim = $AnimatedSprite2D/HurtboxAnim


@export_category("Spawn")
@export var external_detection_area : Area2D
@export var strategy : MobStrategy = MobStrategy.LAZY
@export var growing : bool = false
@export_range(0, 1) var spawn_weight : float
@export_range(0, 5) var difficulty_scalar : float = 1

@export_category("Movement")
@export var chase_time : float = 3
@export var move_speed : float
@export var acceleration : float = .2
@export var wander_distance : float = 10
@export var inertia : float = 10
@export var flying : bool = false

@export_category("Death")
@export var max_health : int
@export var bleeds : bool = false
@export var death_particles : bool = true
@export var xp_value : int = 0
@export var drops_items : Array[ItemData]

@export_category("Attack")
@export_range(20, 100) var attack_distance : int = 20
@export var cooldown: float = 2
@export var player_damage = randf_range(1, 7)


var knockback = Vector2.ZERO
var original_pos : Vector2
var move_target : Vector2
var chase_timer : float = chase_time
var cry_played : bool = false
var attack_cooldown : float = cooldown :
	set(value):
		attack_cooldown = clampf(value, 0, cooldown)


enum MobStrategy {
	CHASE,
	LAZY,
	PATH,
	WAIT
}


enum MobState {
	CHASING,
	IDLE,
	ATTACKING,
	SPECIAL,
	DEAD
}

var state : MobState = MobState.IDLE
var health : int


func init(init_strategy: MobStrategy = MobStrategy.LAZY, pos : Vector2 = global_position):
	if init_strategy == MobStrategy.LAZY:
		state = MobState.IDLE
	elif init_strategy == MobStrategy.CHASE:
		state = MobState.CHASING
	global_position = pos
	move_target = global_position
	original_pos = global_position
	return self

func _ready():
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	move_target = global_position
	original_pos = global_position
	health = max_health
	z_index = 1
	animated_sprite_2d.connect("animation_finished", _on_animation_finished)
	set_collisions()

func set_collisions():
	if flying:
		for i in [7, 8]:
			set_collision_mask_value(i, true)
		set_collision_layer_value(7, true)
	else:
		for i in [2, 3, 5, 8, 9]:
			set_collision_mask_value(i, true)
		set_collision_layer_value(3, true)

func _physics_process(delta):
	var detect_player = PlayerManager.player.state != PlayerManager.player.PlayerState.DEAD\
		and detection_area.overlaps_body(PlayerManager.player) \
		or strategy == MobStrategy.CHASE
	var close_to_player = global_position.distance_to(PlayerManager.get_global_position()) < attack_distance
	attack_cooldown -= 1 * delta
	chase_timer -= 1 * delta
	if health <= 0:
		state = MobState.DEAD
	match state:
		MobState.SPECIAL:
			pass
		MobState.DEAD:
			velocity = Vector2.ZERO
			hitbox.set_deferred("disabled", true)
		MobState.ATTACKING:
			if close_to_player and attack_cooldown <= 0:
				velocity = Vector2(0,0)
				if hurtbox.overlaps_body(PlayerManager.player):
					attack_cooldown = cooldown
					damage_player()
					state = MobState.CHASING
			else:
				state = MobState.CHASING

		MobState.CHASING:
			chase(delta, PlayerManager.player)
			if detect_player:
				chase_timer = chase_time
				if close_to_player:
					state = MobState.ATTACKING
			
				
				
			elif chase_timer <= 0:
				if strategy == MobStrategy.LAZY:
					state = MobState.IDLE


		MobState.IDLE:
			if detect_player:
				state = MobState.CHASING
			else:
				idle(delta)

	#print("state: ", MobState.keys()[state], \
	#" | detects player: ", detect_player, \
	#" | close: ", close_to_player,\
	#" | attack cooldown: ", snapped(attack_cooldown, 1))



	knockback = lerp(knockback, Vector2.ZERO, 0.1)
	velocity = velocity + knockback
	animate()
	move_and_slide()


func damage_player():
	PlayerManager.player.take_damage(player_damage, global_position.direction_to(PlayerManager.player.global_position).rotated(global_rotation))

func chase(delta, chase_target : CharacterBody2D = PlayerManager.player) -> void:
	if not cry_played:
		cry_sound.play()
		cry_played = true
	var destination = global_position.direction_to(chase_target.global_position)
	velocity = lerp(velocity, destination * move_speed, acceleration * delta)
	detection_area.look_at(global_position + velocity)

func idle(delta) -> void:
	detection_area.rotation_degrees = 180 if animated_sprite_2d.flip_h else 0
	if idle_timer.is_stopped():
		velocity = Vector2.ZERO
		if randi()%100 > 60:
			var new_position = original_pos.normalized() * Vector2(randf_range(-wander_distance, wander_distance),randf_range(-wander_distance, wander_distance))
			if go_to_target(delta, new_position):
				idle_timer.start()
		idle_timer.start()
		cry_played = false

func go_to_target(delta, target: Vector2) -> bool:
	if target:
		move_target = target
	if abs(global_position - move_target) < Vector2(5, 5):
		velocity = Vector2.ZERO
		return true
	else:
		velocity = lerp(velocity, target * move_speed, acceleration * delta)
	return false


func animate():
	var current_animation : String
	if not state == MobState.DEAD:
		match state:
			MobState.ATTACKING:
				hurtbox_anim.play("attack")
				animated_sprite_2d.scale.x = 1 if global_position.x - PlayerManager.player.global_position.x < 0 else -1
			MobState.IDLE, MobState.CHASING:
				if !velocity:
					current_animation = "idle"
				if velocity.x != 0:
					current_animation = "x_walk" if animated_sprite_2d.sprite_frames.has_animation("x_walk") else "idle"
					animated_sprite_2d.scale.x = 1 if velocity.x > 0 else -1
				elif velocity.y > velocity.x:
					current_animation = "y_walk" if animated_sprite_2d.sprite_frames.has_animation("y_walk") else "idle"

		animated_sprite_2d.play(current_animation)

func take_damage(hit, vector: Vector2, extra_force: float = 0):
	chase_timer = chase_time
	if state == MobState.IDLE:
		state = MobState.CHASING
	UIManager.float_message(["%s" % hit], global_position, -vector)
	var tween: Tween = create_tween()
	tween.tween_property(animated_sprite_2d, "modulate:v", 1, 0.25).set_trans(Tween.TRANS_ELASTIC).from(15)
	knockback = Vector2(hit + extra_force, hit + extra_force) * -vector
	if health > 0:
		health -= hit
	if health <= 0:
		die(vector)

func die(_vector):
	state = MobState.DEAD
	hitbox.set_deferred("disabled", true)
	var timer = Timer.new()
	timer.connect("timeout", _on_death_animation_timer_timeout)
	
	drop_loot()	
	
	if death_particles:
		timer.wait_time = cpu_particles_2d.lifetime
		cpu_particles_2d.emitting = true
		timer.autostart = true
	velocity = lerp(velocity, Vector2.ZERO, .2)
	animated_sprite_2d.play("die")
	add_child(timer)

func drop_loot():
	if drops_items.size() >= 1:
		var loot = drops_items.filter(func(item): if item.drop_rarity <= randf(): return item)
		if loot:
			var new_item = loot.pick_random()
			var pick_up = PICKUP_ITEM.instantiate()
			pick_up.slot_data = SlotData.new()
			pick_up.slot_data.item_data = new_item
			pick_up.position = global_position
			MapManager.current_map.call_deferred("add_child", pick_up)


func wake_up(body):
	if body is Player:
		state = MobState.CHASING

func _on_death_animation_timer_timeout():
	queue_free()

func _on_animation_finished():
	if state == MobState.ATTACKING:
		state = MobState.CHASING
	if state == MobState.DEAD:
		var tween : Tween = create_tween()
		tween.tween_property(animated_sprite_2d, "modulate:a", 0, 0.25)
