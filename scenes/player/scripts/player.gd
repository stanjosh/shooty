extends CharacterBody2D
class_name Player

signal player_died


@onready var sword := $pivot/sword
@onready var animated_sprite_2d := $AnimatedSprite2D
@onready var hitbox := $Hitbox
@onready var dash_cooldown_timer := $DashCooldown
@onready var interaction_area = $InteractionArea
@onready var inflictions = $Inflictions



@export var base_speed : float = 100.0
@export var base_max_health : float = 100
@export var base_dash_speed : float = 180
@export var base_dash_cooldown : float = 2
@export var dash_time : float = .5

var speed : float = 0:
	get:
		return speed + base_speed

var max_health : float = 0  :
	set(value):
		health = clampf(health, 0, max_health)
		max_health = value
	get:
		return max_health + base_max_health
	
var dash_speed : float = 0 :
	get:
		return dash_speed + base_dash_speed

var dash_cooldown : float = 0 :
	set(new_value):
		dash_cooldown_timer.wait_time = new_value
		dash_cooldown = new_value
	get:
		return dash_cooldown + base_dash_cooldown

var health : float = max_health :
	set(value):
		health = clampf(value, 0, max_health)
		Hud.update_hud.emit(Hud.Element.HEALTH, health, max_health)

@export var inventory_data : InventoryData = InventoryData.new()
@export var equip_inventory_datas : Array[InventoryDataEquip]

var can_dash : bool = true
var status : Dictionary

var current_level : int = 1
var is_alive : bool = true
var animation_lock : bool = false
var melee_attacking : bool = false
var dashing : bool = false
var danger_level : float
var knockback := Vector2.ZERO
signal toggle_inventory

enum PlayerState {
	MELEE,
	DASHING,
	IDLE,
	DEAD
}

var state : PlayerState = PlayerState.IDLE

func _ready():
	health = base_max_health
	print(health)
	$DashTimer.wait_time = dash_time
	for equip_inventory_data in equip_inventory_datas:
		equip_inventory_data.connect("inventory_updated", equip_items)
	PlayerManager.level_up.connect(_on_level_up)
	InventoryManager.refresh(self)
	for stat in stat_names.values():
		update_status_panel(stat)


func _unhandled_input(event):
	if state != PlayerState.DEAD:


		if event.is_action_released("dash") \
		and state != PlayerState.DASHING \
		and dash_cooldown_timer.is_stopped():
			state = PlayerState.DASHING
			dash()
		if event.is_action_pressed("sword") and state != PlayerState.MELEE:
			state = PlayerState.MELEE if melee_attack() else PlayerState.IDLE
				

		
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
			$pivot.rotation = Vector2(xAxisRL, yAxisUD).angle()
		else:	
			$pivot.look_at(get_global_mouse_position())

func animate():
	var current_animation : String
	
	if state == PlayerState.DASHING:
		if abs(velocity.x) > abs(velocity.y):
			animated_sprite_2d.flip_h = true if velocity.x < 0 else false
			current_animation = "x_dash"
		else:
			if velocity.y > 0:
				current_animation = "down_dash"
			else:
				current_animation = "up_dash"
	
	elif not animation_lock:
		var pivot = wrapi(snapped(get_angle_to(get_global_mouse_position()), PI/4) / (PI/4), 1, 8)
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
	if state in [PlayerState.MELEE, PlayerState.DEAD]:
		animation_lock = true

func _physics_process(_delta):
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
	knockback = lerp(knockback, Vector2.ZERO, .1)
	velocity = velocity + knockback
	move_and_slide()
	animate()


func dash() -> void:
	print("dash_time: ", dash_time)
	$DashTimer.wait_time = dash_time
	$DashTimer.start()
	$DashParticles.lifetime = 2 * dash_time
	$DashParticles.emitting = true
	$DashSound.play()

func melee_attack() -> bool:
	var mines = $pivot/Area2D.get_overlapping_bodies().filter(func(body): return body is Mine)
	if mines:
		global_position = mines.front().global_position
		if not mines.front().delay:
			mines.front().explode()
	return sword.attack()

func take_damage(hit: float, vector: Vector2, extra_force: float = 0):
	hit = snapped(hit, 1)
	Hud.float_message(["%s"%hit], global_position, vector )
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite_2d, "modulate:v", 1, 0.25).from(15)
	health -= hit
	knockback = Vector2(20 * hit + extra_force, 20 * hit + extra_force) * vector
	if health <= 0:
		health = 0
		die()



func die():
	state = PlayerState.DEAD
	animated_sprite_2d.play("die")
	animation_lock = true
	velocity = Vector2.ZERO
	$pivot.process_mode = Node.PROCESS_MODE_DISABLED
	$DeathParticles.emitting = true
	player_died.emit()
	var tween :Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, $DeathParticles.lifetime).set_ease(Tween.EASE_IN)

func heal(value):
	health = clampf(health + value, 0, max_health)


var level_changes : Dictionary = {
		1 : {
		},
		2 : {
			"max_health" : 2
		},
		3 : {
			"max_health" : 3,
			"speed" : 4
		},
		4 : {
			"max_health" : 4,

		},
		5 : {
			"max_health" : 5,
			"speed" : 4
		},
		6 : {
			"max_health" : 6,

		},
	}

var stat_names = {
	EquipStat.StatName.AREA : "speed",
	EquipStat.StatName.ACCURACY : "dash_speed",
	EquipStat.StatName.COOLDOWN : "dash_cooldown",
	EquipStat.StatName.CAPACITY : "max_health",
	EquipStat.StatName.SPECIAL : "speed" 
}



func update_status_panel(stat_name: String):
	var pretty_names := {
		 "current_level" : "Player level",
		 "speed" : "Move speed",
		 "max_health" : "Player health",
		 "dash_cooldown" : "Dash cooldown", 
		 "dash_speed" : "Dash speed",
	}
	Hud.update_stats.emit(pretty_names[stat_name], get(stat_name))

var current_stat_upgrades : Dictionary

func equip_items(_inventory_data: InventoryDataEquip):
	if _inventory_data.upgrade_target == InventoryDataEquip.UpgradeTarget.PLAYER:
		current_stat_upgrades.clear()
		
		current_stat_upgrades = _inventory_data.consolidated()
		print(current_stat_upgrades)
		for stat_name in stat_names:
			var value = current_stat_upgrades[stat_name] if current_stat_upgrades.has(stat_name) else 0
			stat_name = stat_names[stat_name]
			
			set(stat_name, value)
			update_status_panel(stat_name)


func _on_level_up():
	for level_reward in level_changes[current_level]:
		set(level_reward, get(level_reward) + level_changes[current_level][level_reward])
	current_level = clampi(current_level + 1, 0, level_changes.size())
	var level_up_message : Array[String] = ["level %s!" % current_level]
	for level_reward in level_changes[current_level]:
		level_up_message.push_back("%s + %s" % [level_reward.replace("_", " "), level_changes[current_level][level_reward]])
	Hud.float_message(level_up_message, global_position)

func _on_animated_sprite_2d_animation_finished():
	if state != PlayerState.DEAD:
		state = PlayerState.IDLE
		set_deferred("animation_lock", false)
	

func _on_dash_cooldown_timeout():
	print("dash cooldown timeout")
	set_deferred("can_dash", true)


func _on_dash_timer_timeout():
	print("dash timer timeout")
	set_deferred("state", PlayerState.IDLE)
	dash_cooldown_timer.start()
