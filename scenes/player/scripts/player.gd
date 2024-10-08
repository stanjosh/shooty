extends CharacterBody2D
class_name Player

signal player_died

@onready var animated_sprite_2d := $AnimatedSprite2D
@onready var hitbox := $Hitbox
@onready var dash_cooldown_timer := $DashCooldown
@onready var interaction_area = $InteractionArea
@onready var inflictions = $Inflictions

@onready var weapons = $Weapons


@export var base_speed : float = 100.0
@export var base_max_health : float = 100
@export var base_dash_speed : float = 180
@export var base_dash_cooldown : float = 2
@export var dash_time : float = .5

var speed : float = 0:
	get:
		return base_speed + speed

var max_health : float = 0  :
	set(value):
		max_health = value
		health = clampf(health, 0, max_health)
	get:
		return base_max_health + (max_health * 10)
	
var dash_speed : float = 0 :
	get:
		return base_dash_speed + (dash_speed * 5)

var dash_cooldown : float = 0 :
	set(new_value):
		dash_cooldown_timer.wait_time = base_dash_cooldown - (dash_cooldown * 0.25)
		dash_cooldown = clampf(new_value, 0, 4)
	get:
		return base_dash_cooldown - (dash_cooldown * 0.25)

var health : float = max_health :
	set(value):
		health = clampf(value, 0, max_health)
		GUI.hud.update("health", health, max_health)

@export var inventory_data : InventoryData

var can_dash : bool = true
var status : Dictionary

var current_level : int = 1
var knockback := Vector2.ZERO
signal toggle_inventory

enum PlayerState {
	MELEE,
	DASHING,
	IDLE,
	DEAD
}

var state : PlayerState = PlayerState.IDLE
var aim_point : Vector2

func _ready() -> void:
	$DashTimer.wait_time = dash_time
	PlayerManager.level_up.connect(_on_level_up)
	GUI.refresh_interface.emit(self)
	update_status_panel()

func _unhandled_input(event) -> void:
	if state != PlayerState.DEAD:
		if event.is_action_released("dash") \
		and state != PlayerState.DASHING \
		and can_dash:
			state = PlayerState.DASHING
			dash()

		if event.is_action_released("interact"):
			var interactables = interaction_area.get_overlapping_areas().filter(func(area): return area is Interactable)
			if interactables:
				interactables[0].interact(self)

		if event.is_action_released("cheat"):
			PlayerManager.give_xp(30)

		if event.is_action_released("inv"):
			toggle_inventory.emit()

		var deadzone = 0.5
		#var controllerangle = Vector2.ZERO
		var xAxisRL = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		var yAxisUD = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		if abs(xAxisRL) > deadzone || abs(yAxisUD) > deadzone:
			$Weapons.rotation = Vector2(xAxisRL, yAxisUD).angle()
			aim_point = $AimPoint.global_position
			Input.warp_mouse(lerp($AimPoint.get_global_transform_with_canvas().origin, self.get_global_transform_with_canvas().origin, .3))
		else:
			
			aim_point = get_global_mouse_position()
			$Weapons.look_at(aim_point)

func animate() -> void:
	var current_animation : String
	%RangedWeapon.visible = false if state == PlayerState.MELEE else true
	%MeleeWeapon.heat_level = %RangedWeapon.heat_level
	if state == PlayerState.DASHING:
		if abs(velocity.x) > abs(velocity.y):
			animated_sprite_2d.flip_h = true if velocity.x < 0 else false
			current_animation = "x_dash"
		else:
			if velocity.y > 0:
				current_animation = "down_dash"
			else:
				current_animation = "up_dash"
	
	
	else:
		var pivot = wrapi(snapped(get_angle_to(aim_point), PI/4) / (PI/4), 1, 8)
		$SwordSprite.z_index = 3 if pivot in [1, 5, 6, 7, 8] else 1
		$SwordSprite.flip_h = true if pivot in [2, 3, 4] else false
		match pivot:
			5:
				if state == PlayerState.MELEE:
					animated_sprite_2d.flip_h = true if pivot == 5 else false
					current_animation = "up_attack"
				elif abs(velocity - knockback):
					current_animation = "up_walk"
				else:
					current_animation = "up_idle"
			2:
				if state == PlayerState.MELEE:
					animated_sprite_2d.flip_h = false if pivot == 2 else true
					current_animation = "down_attack"
				elif abs(velocity - knockback):
					current_animation = "down_walk"
				else:
					current_animation = "down_idle"
			_:
				animated_sprite_2d.flip_h = true if pivot in [3, 4] else false
				if state == PlayerState.MELEE:
					current_animation = "x_attack"
				elif abs(velocity - knockback):
					current_animation = "x_walk"
				else:
					current_animation = "x_idle"
	animated_sprite_2d.play(current_animation)

func _physics_process(_delta) -> void:
	if state == PlayerState.DEAD:
		velocity = Vector2.ZERO
		hitbox.disabled = true
	else:
		var input_direction : Vector2 = Input.get_vector("left", "right", "up", "down")
		if state != PlayerState.DASHING:
			velocity = input_direction * speed
		else:
			velocity = input_direction * dash_speed
		if not input_direction:
			velocity = Vector2(0,0)
	knockback = lerp(knockback, Vector2.ZERO, .2)
	velocity = velocity + knockback
	move_and_slide()
	animate()


func dash() -> void:
	can_dash = false
	$DashTimer.wait_time = dash_time
	$DashTimer.start()
	$DashParticles.lifetime = dash_time
	$DashParticles.emitting = true
	$DashSound.play()


func take_damage(hit: float, vector: Vector2, extra_force: float = 0) -> void:
	hit = snapped(hit, 1)
	GUI.float_message(["%s"%hit], self, vector )
	$HurtSound.play()
	hit_pause()
	flash_sprite()
	
	health -= hit
	knockback = Vector2(20 * hit + extra_force, 20 * hit + extra_force) * vector
	if health <= 0:
		health = 0
		die()

func hit_pause() -> void:
	get_tree().create_tween().tween_property(Engine, "time_scale", 1, 0.2).from(0.01)
	
func flash_sprite() -> void:
	get_tree().create_tween().tween_property(animated_sprite_2d, "modulate:v", 1, 0.15).from(0)

func die() -> void:
	state = PlayerState.DEAD
	animated_sprite_2d.play("die")
	velocity = Vector2.ZERO
	$Weapons.process_mode = Node.PROCESS_MODE_DISABLED
	$DeathParticles.emitting = true
	player_died.emit()
	var tween :Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, $DeathParticles.lifetime).set_ease(Tween.EASE_IN)

func heal(value):
	health = clampf(health + value, 0, max_health)


var level_changes : Dictionary = {
		2 : {
			"max_health" : 2,
			"dash_time" : 1
		},
		3 : {
			"max_health" : 1,
			"speed" : 4
		},
		4 : {
			"max_health" : 2,

		},
		5 : {
			"max_health" : 1,
			"dash_speed" : 4
		},
		6 : {
			"max_health" : 1,

		},
	}


func update_status_panel(stat_name: String = "") -> void:
	var pretty_names := {
		 "current_level" : "Player level",
		 "speed" : "Move speed",
		 "max_health" : "Player health",
		 "dash_cooldown" : "Dash cooldown", 
		 "dash_speed" : "Dash speed",
	}
	if !stat_name:
		for stat in pretty_names.keys():
			GUI.update_stats.emit(pretty_names[stat], get(stat))
	else:
		GUI.update_stats.emit(pretty_names[stat_name], get(stat_name))
	

var current_stat_upgrades : Dictionary


func _on_level_up() -> void:
	current_level = clampi(current_level + 1, 0, level_changes.size())
	for level_reward in level_changes[current_level]:
		set(level_reward, level_changes[current_level][level_reward])
	var level_up_message : Array[String] = ["level %s!" % current_level]
	for level_reward in level_changes[current_level]:
		level_up_message.push_back("%s + %s" % [level_reward.replace("_", " "), level_changes[current_level][level_reward]])
	GUI.float_message(level_up_message, self)

func _on_melee_attack() -> void:
	state = PlayerState.MELEE

func _on_animated_sprite_2d_animation_finished() -> void:
	if state != PlayerState.DEAD:
		state = PlayerState.IDLE
		set_deferred("animation_lock", false)
	

func _on_dash_cooldown_timeout() -> void:
	set_deferred("can_dash", true)


func _on_dash_timer_timeout() -> void:
	set_deferred("state", PlayerState.IDLE)
	dash_cooldown_timer.start()
