extends CharacterBody2D
class_name Mob

signal player_detected

#@onready var navigation_agent_2d := $NavigationAgent2D
@onready var hurtbox : Area2D = $Hurtbox
@onready var idle_timer : Timer = $IdleTimer
@onready var cry_sound : AudioStreamPlayer2D = $CrySound
@onready var sprite_2d = $Sprite2D
@onready var hitbox := $Hitbox
@onready var detection_area : Area2D = $DetectionArea
@onready var animation :AnimationPlayer = $Animation


@export_category("Spawn")
@export var external_detection_area : Area2D :
	set(value):
		external_detection_area = value
		if external_detection_area:
			external_detection_area.body_entered.connect(wake_up)
@export var strategy : MobStrategy = MobStrategy.LAZY
@export var growing : bool = false
@export_range(0, 1) var spawn_weight : float
@export_range(0, 5) var difficulty_scalar : float = 1

@export_category("Movement")
@export var chase_time : float = 3
@export var move_speed : float
@export var inertia : float = 10
@export var acceleration : float = .2
@export var wander_distance : float = 10
@export var flying : bool = false

@export_category("Death")
@export var max_health : int
@export var bleeds : bool = false
@export var xp_value : int = 0
@export var drops_items : Array[ItemData] # maybe make droptable resource

@export_category("Attack")
@export var special_attack_cooldown: float = 2
@export var player_damage = randf_range(1, 7)


var knockback := Vector2.ZERO
var original_pos : Vector2
var move_target : Vector2
var chase_timer : float = chase_time
var cry_played : bool = false
var special_timer : float = special_attack_cooldown


enum MobStrategy {
	CHASE,
	LAZY,
	PATH,
	WAIT,
	DUMMY
}


enum MobState {
	CHASING,
	MOVING,
	IDLE,
	ATTACKING,
	SPECIAL,
	DEAD,
	DUMMY
}

var state : MobState = MobState.IDLE
var health : int

func _ready():
	if strategy == MobStrategy.CHASE:
		state = MobState.CHASING
	if strategy == MobStrategy.DUMMY:
		state = MobState.DUMMY
	animation.animation_finished.connect(_on_animation_finished)
	detection_area.body_entered.connect(wake_up)
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	move_target = global_position
	original_pos = global_position
	health = max_health
	z_index = 1
	set_collisions()

func set_collisions():
	if flying:
		for i in [3, 8]:
			set_collision_mask_value(i, true)
		set_collision_layer_value(3, true)
	else:
		for i in [2, 5, 8, 9]:
			set_collision_mask_value(i, true)
		set_collision_layer_value(7, true)

func _process(delta):
	if health <= 0:
		state = MobState.DEAD
	match state:
		MobState.DEAD:
			flip_sprite()
			die(delta)
		MobState.ATTACKING:
			flip_sprite()
			velocity = Vector2.ZERO
			animation.play("attack")
		MobState.MOVING:
			flip_sprite()
			animation.play("walk")
			state = go_to_target(delta)
		MobState.CHASING:
			flip_sprite()
			animation.play("walk")
			state = chase(delta)
		MobState.IDLE:
			animation.play("idle")
			state = idle()
		MobState.SPECIAL:
			state = special_attack(delta)
		MobState.DUMMY:
			health = clampi(lerp(health, max_health, delta), 1, max_health)
			
	#print("state: ", MobState.keys()[state], \
	#" | detects player: ", detects_player(), \
	#" | close: ", hurtbox.overlaps_body(PlayerManager.player),\
	#" | idle timer: ", snapped(idle_timer.time_left, 1))
	


func _physics_process(delta):
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
	velocity = velocity + knockback * delta
	move_and_slide()

func detects_player() -> bool:
	return detection_area.overlaps_body(PlayerManager.player) \
		or strategy == MobStrategy.CHASE


func chase(delta, chase_target : Node2D = PlayerManager.player) -> MobState:
	special_timer -= delta
	chase_timer = chase_time if detects_player() else chase_timer - delta
	if chase_timer < 0 and not strategy == MobStrategy.CHASE:
		return MobState.IDLE
	if not cry_played:
		cry_sound.play()
		cry_played = true
	if hurtbox.overlaps_body(PlayerManager.player):
		return MobState.ATTACKING
	elif special_timer <= 0:
		return MobState.SPECIAL
	var destination = global_position.direction_to(chase_target.global_position)
	velocity = lerp(velocity, destination * move_speed, acceleration * delta)
	detection_area.look_at(global_position + velocity)
	return MobState.CHASING



func idle() -> MobState:
	velocity = Vector2.ZERO
	cry_played = false
	if idle_timer.is_stopped():
		idle_timer.start()
		if randf() > .4:
			var offset_x = original_pos.x + randf_range(-wander_distance, wander_distance)
			var offset_y = original_pos.y + randf_range(-wander_distance, wander_distance)
			move_target = Vector2(offset_x, offset_y)
			return MobState.MOVING
	return MobState.IDLE

func go_to_target(delta, target = move_target) -> MobState:
	var destination = global_position.direction_to(target)
	if global_position.distance_to(target) < 10:
		return MobState.IDLE
	velocity = lerp(velocity, destination * move_speed * 0.75, acceleration * delta)
	return MobState.MOVING

func special_attack(_delta) -> MobState:
	return MobState.CHASING

func damage_target(body: Node2D):
	if body.has_method("take_damage"):
		body.take_damage(player_damage, global_position.direction_to(body.global_position))

func take_damage(hit, vector: Vector2, extra_force: float = 0):
	GUI.float_message(["%s" % hit], self, vector * hit)
	knockback = Vector2(hit + extra_force, hit + extra_force) * vector
	chase_timer = chase_time
	flash_sprite()
	if state == MobState.IDLE:
		state = MobState.CHASING
	if bleeds:
		add_child(BloodSpray.new(vector))
	if health > 0:
		health -= hit
	if health <= 0:
		die(vector)

func flash_sprite():
	var tween: Tween = create_tween()
	tween.tween_property(sprite_2d, "modulate:v", 1, 0.25).set_trans(Tween.TRANS_ELASTIC).from(15)
	

func die(_vector) -> void:
	velocity = lerp(velocity, Vector2.ZERO, .2)
	drop_loot()	
	animation.play("die")
	

func flip_sprite():
	sprite_2d.flip_h = velocity.x < 0
	detection_area.rotation_degrees = 180 if sprite_2d.flip_h else 0


func drop_loot():
	if drops_items.size() >= 1:
		var loot = drops_items.filter(func(item): if item.drop_rarity <= randf(): return item)
		MapManager.drop_item(loot, global_position)


func wake_up(body):
	if body is Player:
		state = MobState.CHASING



func _on_animation_finished(_animation):
	if _animation == "die":
		queue_free() 
	if _animation == "attack":
		if hurtbox.overlaps_body(PlayerManager.player):
			damage_target(PlayerManager.player)
		state = MobState.CHASING
