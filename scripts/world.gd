extends Node2D

@onready var spawner = %spawner

@onready var player = $player

const INITIAL_SPAWNS : int = 20

@export var spawn_timer : float = .5
@export var max_spawns : int
@export var danger_factor : float = 1

var kill_count: int


func process_danger():
	var danger : float
	if danger_factor < 1:
		danger_factor = 1
	danger += clampf(1 - (100 / player.health), 0, 1)
	danger += player.combo_counter / 25
	danger_factor = player.hitters.size() + clampf(snapped(danger, .10), 1, 5)


func spawn_mob():
	var new_mob = preload("res://scenes/mob.tscn").instantiate()
	spawner.progress_ratio = randf()
	new_mob.global_position = spawner.global_position
	new_mob.move_speed = 28 + (danger_factor * 2)
	add_child(new_mob)
	max_spawns  = INITIAL_SPAWNS + (2 * danger_factor)

func _physics_process(delta):
	process_danger()
	max_spawns = INITIAL_SPAWNS + (2 * danger_factor)
	spawn_timer -= 1 * delta
	var mobs = get_children().filter(func(child): return child is Mob)
	var allowed_spawns = max_spawns - mobs.size()
	if spawn_timer <= 0 and allowed_spawns >= 1:
		spawn_mob()
		print("mobs: ", mobs.size(), "/", max_spawns, " allowed: ", allowed_spawns)
			
		
