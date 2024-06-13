extends Weapon


const MINE = preload("res://scenes/player/weapons/mine.tscn")
@export var mine_timer : float = 1
@export var max_mines : int = 1
@export_range(1, 3) var launch_speed : float = 2
@export var recharge_speed : float = 1
@export var detonator : bool = false

func _ready():
	Hud.update_hud.emit("MineCounter", snapped(mine_timer, 1), max_mines)

func _physics_process(delta):
	if mine_timer <= 1 and get_children().filter(func(child): return child is Mine).size() < max_mines:
		mine_timer += recharge_speed * delta
		Hud.update_hud.emit("MineCounter", snapped(mine_timer, 1), max_mines)
	if Input.is_action_pressed("mine"):
		throw_mine()
	if Input.is_action_just_pressed("mine detonate") and detonator:
		detonate_mines()
		
func throw_mine():
	if mine_timer >= 1:
		var new_mine = MINE.instantiate() as RigidBody2D
		new_mine.global_position = %barrel.global_position
		new_mine.speed = global_position.distance_to(get_global_mouse_position())
		new_mine.linear_velocity = (get_global_mouse_position() - global_position).normalized() * (new_mine.speed * launch_speed)
		add_child(new_mine)
		mine_timer = 0
		Hud.update_hud.emit("MineCounter", snapped(mine_timer, 1), max_mines)

func detonate_mines():
	for target_mine in get_children().filter(func(child): return child is Mine):
		target_mine.explode()
	Hud.update_hud.emit("MineCounter", snapped(mine_timer, 1), max_mines)
