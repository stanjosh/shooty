extends Weapon



@onready var gun_click = $gun_click

@onready var gun = $Gun

@export var damage : float = 8
@export var piercing : int = 0
@export var magazine : int = 6
@export var fire_rate : float = 4
@export var accuracy : float = .03
@export var pellets : int = 1
@export var dropoff : float = 15
@export var cooldown : float = 3
@export var projectile : PackedScene = preload("res://scenes/player/weapons/bullet.tscn")

var item_name : String = "Gun"
var overheated : bool = false


@onready var world = get_node("/root/Game/World")

var current_level : int = 1
var current_magazine : int = magazine
var shot_time : float = 0
var facing : Vector2
var status : Dictionary

func _ready():
	Hud.float_message(["Got the gun!"], global_position)
	PlayerStatus.level_up.connect(_on_level_up)
	Hud.update_hud.emit("AmmoCounter", current_magazine, magazine)
	update_status()


func _physics_process(delta):
	$PointLight2D.energy = clamp($PointLight2D.energy - 1 * delta, 0, 1)
	modulate.b = clampf(float(current_magazine * 2) / (float(magazine)), 0, 1)
	modulate.g = clampf(float(current_magazine * 2) / (float(magazine)), 0, 1)
	

	shot_time -= fire_rate * delta * 100 
	
	facing = gun.global_position.direction_to($"..".global_position)
	
	gun.flip_v = true if facing.x > 0 else false
	gun.z_index = 2 if facing.y > 0 and facing.x < 1 else 4
	if Input.is_action_pressed("shoot"):
		shoot(delta)

func shoot(_delta):
	if not overheated and shot_time <= 0:
		$AnimationPlayer.stop()
		$AnimationPlayer.play("shoot")
		current_magazine -= 1
		for n in pellets:
			var new_bullet = projectile.instantiate()
			new_bullet.global_position = %barrel.global_position
			new_bullet.global_rotation = %barrel.global_rotation + randf_range(0, accuracy)
			new_bullet.piercing += piercing
			new_bullet.damage += damage
			new_bullet.dropoff += dropoff
			%barrel.add_child(new_bullet)
			shot_time = 100
			$PointLight2D.energy = clamp($PointLight2D.energy + .4, 0, 2)
	if not overheated and current_magazine == 0:
		
		overheated = true
		$Overheat.wait_time = cooldown
		$Overheat.start()
	Hud.update_hud.emit("AmmoCounter", current_magazine, magazine)

func update_status():
	status = {
		"gun level" : current_level,
		"gun damage" : damage,
		"gun magazine" : magazine,
		"gun fire rate" : fire_rate,
		"gun pellets" : pellets,
		"gun cooldown" : cooldown
	}
	for item in status.keys():
		Hud.stats[item] = status[item]

var level_changes : Dictionary = {
		2 : {
			"damage" : .5
		},
		3 : {
			"fire_rate" : .02,
			"cooldown" : -.3
		},
		4 : {
			"pellets" : 1
		},
		5 : {
			"damage" : .02,
			"piercing" : 1
		},
		6 : {
			"pellets" : 1
		},
	}

func _on_level_up():
	current_level = clampi( current_level + 1, 0, level_changes.size())
	var lines : int = level_changes[current_level].size()
	for level_reward in level_changes[current_level]:
		set(level_reward, get(level_reward) + level_changes[current_level][level_reward])
	update_status()

func _on_cooldown_timeout():
	
	if not overheated and current_magazine < magazine:
		current_magazine += 1
		Hud.update_hud.emit("AmmoCounter", current_magazine, magazine)


func _on_overheat_timeout():
	overheated = false
	current_magazine = magazine
	Hud.update_hud.emit("AmmoCounter", current_magazine, magazine)

