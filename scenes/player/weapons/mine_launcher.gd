extends Node2D


const mine = preload("res://scenes/player/weapons/mine.tscn")
@onready var world = $"../../.."
@export var mine_timer : float = 1
@export var max_mines : int = 1
@export_range(1, 3) var launch_speed : float = 1
@export var recharge_speed : float = 1
@export var detonator : bool = false

func _ready():
	Hud.update_hud.emit("MineCounter", snapped(mine_timer, 1), max_mines)

func _physics_process(delta):
	if mine_timer <= 1 and world.active_mines.size() < max_mines:
		mine_timer += recharge_speed * delta
		Hud.update_hud.emit("MineCounter", snapped(mine_timer, 1), max_mines)
	if Input.is_action_pressed("mine"):
		throw_mine()
	if Input.is_action_just_pressed("mine detonate") and detonator:
		detonate_mines()
		
func throw_mine():
	if mine_timer >= 1:
		var mine = mine.instantiate() as RigidBody2D
		mine.global_position = %angle.global_position
		mine.speed = global_position.distance_to(get_global_mouse_position())
		mine.linear_velocity = (get_global_mouse_position() - global_position).normalized() * (mine.speed * launch_speed)
		

		world.add_child(mine)
		mine_timer = 0
		Hud.update_hud.emit("MineCounter", snapped(mine_timer, 1), max_mines)

func detonate_mines():
	for mine in world.active_mines:
		mine.explode()
	Hud.update_hud.emit("MineCounter", snapped(mine_timer, 1), max_mines)
