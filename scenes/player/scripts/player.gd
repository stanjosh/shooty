extends CharacterBody2D
class_name Player

@onready var world = $".."

@onready var sword := $pivot/sword
@onready var animated_sprite_2d := $AnimatedSprite2D
@onready var hitbox := $hitbox
@onready var camera := $PositionalCamera

@export var speed : float = 100.0
@export var max_health : float = 100
@export var dash_speed : float = 125.0


@export var inventory_data : InventoryData
@export var equip_inventory_data : InventoryDataEquip

var can_dash : bool = true
var status : Dictionary


const ACTION_LINE = preload("res://scenes/effects/action_line.tscn")

var health : float = max_health

var current_level : int = 1
var is_alive : bool = true
var animation_lock : bool = false
var melee_attack : bool = false
var danger_level : float

var stat_mods : Dictionary

signal toggle_inventory

func _ready():
	equip_inventory_data.connect("inventory_updated", equip_items)
	PlayerManager.level_up.connect(_on_level_up)
	update_status()
	
	
func equip_items(inventory_data):
	stat_mods.clear()
	for slot_data in inventory_data.slot_datas:
		if slot_data and slot_data.item_data and slot_data.item_data.upgrades:
			for item in slot_data.item_data.upgrades:
				stat_mods[item.upgrade_stat] = item.upgrade_value
	update_status()

func modified_stat(stat : String) -> float:
	pass
	

func _physics_process(delta):
	melee_attack = false
	if is_alive:
		var input_direction : Vector2 = Input.get_vector("left", "right", "up", "down")

		if Input.is_action_just_pressed("cheat"):
			PlayerManager.give_xp(30)

		if Input.is_action_just_pressed("inv"):
			toggle_inventory.emit()

		var deadzone = 0.5
		#var controllerangle = Vector2.ZERO
		var xAxisRL = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		var yAxisUD = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)

		if abs(xAxisRL) > deadzone || abs(yAxisUD) > deadzone:
			$pivot.rotation = Vector2(xAxisRL, yAxisUD).angle()
		else:	
			$pivot.look_at(get_global_mouse_position())

		if Input.is_action_pressed("sword") and not animation_lock:
			var mines = $pivot/Area2D.get_overlapping_bodies().filter(func(body): return body is Mine)
			if mines:
				global_position = mines.front().global_position
				if not mines.front().delay:
					mines.front().explode()
			melee_attack = sword.attack()

		if Input.is_action_just_pressed("interact"):
			var interactables = hitbox.get_overlapping_areas().filter(func(area): return area is Interactable)
			if interactables:
				interactables[0].interact(self)
				


			
		
		if Input.is_action_pressed("dash") and can_dash and input_direction:
			$DashCooldown.start()
			if not $DashTimer.time_left:
				$DashTimer.start()
			velocity = input_direction * (speed + dash_speed)
			$DashParticles.lifetime = 2 * $DashTimer.wait_time
			$DashParticles.emitting = true
			$CollisionShape2D.disabled = true
		elif input_direction:
			velocity = input_direction * speed
		elif not input_direction:
			velocity = Vector2(0,0)

		max_slides = 5

		move_and_slide()
		animate(delta)

func get_danger():
	return danger_level

func take_damage(hit, vector):
	health -= hit
	global_position += Vector2(hit, hit).rotated(vector)
	var tween: Tween = create_tween()
	tween.tween_property(animated_sprite_2d, "modulate:v", 1, 0.25).from(15)
	
	if health <= 0:
		health = 0
		die()

	Hud.update_hud.emit(Hud.Element.HEALTH, health, max_health)

func heal(value):
	health = clampi(health + value, 0, max_health)
	Hud.update_hud.emit(Hud.Element.HEALTH, health, max_health)

func animate(delta):
	if modulate.g < 1 or modulate.b < 1:
		modulate.g += 2 * delta
		modulate.b += 2 * delta


	if not is_alive:
		animated_sprite_2d.play("die")
		animation_lock = true

	if not animation_lock:
		if melee_attack:
			$pivot.hide()
			animation_lock = true
		var current_animation = ""

		var pivot = snapped(position.angle_to_point($pivot/angle.global_position), 1)



		if pivot < 0 and pivot > -3 :
			animated_sprite_2d.flip_h = true if pivot == -2 or pivot == -3 else false
			if melee_attack:
				current_animation = "up_attack"
			elif abs(velocity):
				current_animation = "up_walk"
			else:
				current_animation = "up_idle"

					
		elif pivot > -1 and pivot < 1:
			animated_sprite_2d.flip_h = false
			if melee_attack:
				current_animation = "x_attack"
			elif abs(velocity):
				current_animation = "x_walk"
			else:
				current_animation = "x_idle"
		
		elif pivot > 0 and pivot < 3:
			animated_sprite_2d.flip_h = false if pivot == 2 or pivot == 3 else true
			if melee_attack:
				current_animation = "down_attack"
			elif abs(velocity):
				current_animation = "down_walk"
			else:
				current_animation = "down_idle"
		
		else:
			animated_sprite_2d.flip_h = true
			if melee_attack:
				current_animation = "x_attack"	
			elif abs(velocity):
				current_animation = "x_walk"
			else:
				current_animation = "x_idle"

		
		animated_sprite_2d.play(current_animation)

func die():
	if is_alive:
		$pivot.process_mode = Node.PROCESS_MODE_DISABLED
		is_alive = false
		animation_lock = true
		animated_sprite_2d.play("die")
		$DeathParticles.emitting = true
		const DEATH_SPRAY = preload("res://scenes/effects/dark_spray.tscn")
		var new_spray = DEATH_SPRAY.instantiate()
		new_spray.global_position = global_position
		new_spray.rotation = randf_range(0, 4)
		world.add_child(new_spray)
		

func update_status():
	status = {
		"level" : current_level,
		"speed" : speed,
		"max_health" : max_health,
		"dash_speed" : dash_speed,
	}
	for item in status.keys():
		Hud.stats[item] = status[item]
	health = clampi(health, 0, max_health)
	Hud.update_hud.emit(Hud.Element.HEALTH, health, max_health)


var level_changes : Dictionary = {
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



	
func _on_level_up():
	current_level = clampi(current_level + 1, 0, level_changes.size() + 1 )
	var level_up_message : Array[String] = ["level %s!" % current_level]
	for level_reward in level_changes[current_level]:
		level_up_message.push_back("%s + %s" % [level_reward.replace("_", " "), level_changes[current_level][level_reward]])
		set(level_reward, get(level_reward) + level_changes[current_level][level_reward])
	Hud.float_message(level_up_message, global_position)
		
	update_status()






func _on_animated_sprite_2d_animation_finished():
	$pivot.show()
	animation_lock = false



func _on_dash_cooldown_timeout():
	print("can dash")
	can_dash = true


func _on_dash_timer_timeout():
	print("no dash")
	$CollisionShape2D.disabled = false
	can_dash = false
