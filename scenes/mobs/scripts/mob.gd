extends CharacterBody2D
class_name Mob

signal player_detected

const PICKUP_ITEM = preload("res://scenes/gui/inventory/items/pickup_item.tscn")
@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox := $Hitbox

#@onready var navigation_agent_2d := $NavigationAgent2D
@onready var cpu_particles_2d := $CPUParticles2D
@onready var detection_area : Area2D = $DetectionArea
@onready var idle_timer : Timer = $IdleTimer
@onready var cry_sound : AudioStreamPlayer2D = $CrySound

@export var growing : bool = false
@export var player_damage = randf_range(1, 7)
@export var move_speed : float
@export var inertia : float = 10
@export var max_health : int
@export var bleeds : bool = false
@export var death_particles : bool = true
@export var flying : bool = false
@export_range(20, 100) var attack_distance : int = 20
@export var xp_value : int = 0
@export var stops_to_attack: bool = true
@export var drops_items : Array[ItemData]

@export_range(0, 5) var difficulty_scalar : float = 1


@export var external_detection_area : Area2D

var original_pos : Vector2
var move_target : Vector2
var cry_played : bool = false

@export var wander_distance : int = 10

enum MobStrategy {
	CHASE,
	LAZY,
	PATH
}

enum MobState {
	CHASING,
	IDLE,
	ATTACKING,
	DEAD
}

var state : MobState

@export var strategy : MobStrategy = MobStrategy.LAZY

var mob_body
var is_alive : bool
var melee_attack : bool = false
var health : int
var animation_lock : bool = false

func _ready():
	original_pos = global_position
	move_target = original_pos
	health = max_health
	animated_sprite_2d.connect("animation_finished", _on_animation_finished)
	set_collisions()
	
	
	if strategy == MobStrategy.LAZY:
		state = MobState.IDLE
		detection_area.body_entered.connect(wake_up)
		if external_detection_area:
			external_detection_area.body_entered.connect(wake_up)


func set_collisions():
	if flying:
		for i in [3, 5, 8]:
			set_collision_mask_value(i, true)
		set_collision_layer_value(7, true)
	else:
		for i in [7, 2, 5, 8]:
			set_collision_mask_value(i, true)
		set_collision_layer_value(3, true)

func _unhandled_input(event):
	if event.is_action_pressed("cheat"):
		move_target = get_global_mouse_position()

func _physics_process(_delta):
	
	if state != MobState.DEAD and strategy == MobStrategy.CHASE and PlayerManager.player.is_alive:
		state = MobState.CHASING



	match state:
		MobState.DEAD:
			hitbox.set_deferred("disabled", true)
		MobState.ATTACKING:
			pass
		MobState.IDLE:
			var mobs = detection_area.get_overlapping_bodies().filter(func(body): return body is Mob)
			if detection_area.overlaps_body(PlayerManager.player):
				chase(PlayerManager.player)
			elif mobs:
				for mob : Mob in mobs:
					if mob.state == MobState.CHASING:
						chase(PlayerManager.player)
			if go_to_target(move_target):
				idle()



		MobState.CHASING:
			if not PlayerManager.player.state == PlayerManager.player.PlayerState.DEAD:
				if strategy == MobStrategy.LAZY:
					if not detection_area.overlaps_body(PlayerManager.player):
						go_to_target(original_pos)
					else:
						chase(PlayerManager.player)
				elif strategy == MobStrategy.CHASE:
						chase(PlayerManager.player)
				if global_position.distance_to(PlayerManager.player.global_position) < attack_distance:
					attack()
			else:
				idle()
	#print("state: ", MobState.keys()[state], " | strategy: ", MobStrategy.keys()[strategy])
	animate()
	move_and_slide()



func go_to_target(target: Vector2 = global_position) -> bool:
	if target:
		move_target = target
	if global_position.distance_to(move_target) < 3:
		move_target = global_position
		idle()
		return true
	else:
		velocity = global_position.direction_to(move_target) * .5 * move_speed
		return false

func chase(chase_target : CharacterBody2D) -> void:
	if not PlayerManager.player.state == PlayerManager.player.PlayerState.DEAD:
		state = MobState.CHASING
		if not cry_played:
			if not SoundManager.sound_was_recently_played(cry_sound.stream):
				SoundManager.register_sound(cry_sound.stream)
				cry_sound.play()
			cry_played = true
		var tween: Tween = create_tween()
		if flying:
			
			tween.tween_property(self, "velocity", global_position.direction_to(chase_target.global_position) * move_speed, inertia).set_trans(Tween.TRANS_ELASTIC)
		else:
			tween.tween_property(self, "velocity", global_position.direction_to(chase_target.global_position) * move_speed, .25).set_trans(Tween.TRANS_LINEAR).from(velocity)

func idle() -> void:

	state = MobState.IDLE
	if idle_timer.is_stopped():
		velocity = Vector2.ZERO		
		if randi()%100 > 80:
			move_target = original_pos + Vector2(randi_range(-wander_distance, wander_distance), randi_range(-wander_distance, wander_distance))
		idle_timer.start()
		cry_played = false



func attack():
	state = MobState.ATTACKING
	if stops_to_attack:
		velocity = Vector2(0,0)

func try_hit_player():
	if MobState.ATTACKING and global_position.distance_to(PlayerManager.player.global_position) < attack_distance:
		PlayerManager.player.take_damage(player_damage, global_position.angle_to_point(PlayerManager.player.global_position))
	state = MobState.CHASING
		
func animate():
	var current_animation : String
	if not state == MobState.DEAD or animation_lock:
		match state:
			MobState.ATTACKING:
				current_animation = "attack"
				animated_sprite_2d.flip_h = false if global_position.x - PlayerManager.player.global_position.x < 0 else true
			MobState.IDLE, MobState.CHASING:
				if !velocity:
					current_animation = "idle"
				if velocity.x != 0:
					current_animation = "x_walk" if animated_sprite_2d.sprite_frames.has_animation("x_walk") else "idle"
					animated_sprite_2d.flip_h = false if velocity.x > 0 else true
				elif velocity.y > velocity.x:
					current_animation = "y_walk" if animated_sprite_2d.sprite_frames.has_animation("y_walk") else "idle"

		animated_sprite_2d.play(current_animation)

func take_damage(hit, vector):
	strategy = MobStrategy.CHASE
	Hud.float_message(["%s" % hit], global_position, vector)
	var tween: Tween = create_tween()
	tween.tween_property(self, "velocity", Vector2(hit * 5, hit * 5).rotated(vector), .25)
	
	tween.tween_property(animated_sprite_2d, "modulate:v", 1, 0.25).set_trans(Tween.TRANS_ELASTIC).from(15)
	if health > 0:
		health -= hit
	if health <= 0:
		is_alive = false
		die(vector)

func die(vector):
	state = MobState.DEAD
	hitbox.set_deferred("disabled", true)
	var timer = Timer.new()
	timer.connect("timeout", _on_death_animation_timer_timeout)
	PlayerManager.give_xp(xp_value)
	
	drop_loot()	
	
	if death_particles:
		timer.wait_time = cpu_particles_2d.lifetime
		cpu_particles_2d.emitting = true
		timer.autostart = true
	if bleeds:
		const DARK_SPRAY = preload("res://scenes/effects/dark_spray.tscn")
		var new_spray = DARK_SPRAY.instantiate()
		new_spray.global_position = hitbox.global_position
		new_spray.rotation = vector
		new_spray.scale = scale
		get_parent().call_deferred("add_child", new_spray)

	animated_sprite_2d.play("die")
	animation_lock = true
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
			get_parent().call_deferred("add_child", pick_up)


func wake_up(body):
	if body is Player:
		state = MobState.CHASING
		set_deferred("is_alive", true)

func _on_death_animation_timer_timeout():
	queue_free()

func _on_animation_finished():
	if state == MobState.ATTACKING:
		try_hit_player()
	if state == MobState.DEAD:
		var tween : Tween = create_tween()
		tween.tween_property(animated_sprite_2d, "modulate:a", 0, 0.25)
