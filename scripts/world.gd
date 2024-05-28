extends Node2D

@onready var spawner = %spawner

@onready var player = $player

const INITIAL_SPAWNS : int = 20

@export var spawn_timer : float = .5
@export var max_spawns : int
@export var danger_factor : float = 0

func _start():
	$AudioStreamPlayer.play()

func process_danger():
	var danger : float
	if danger_factor <= 0 :
		danger_factor = 0
	danger += clampf(1 - (100 / player.health), 0, 1)
	danger += player.combo_counter / 25
	danger_factor = player.attackers.size() + clampf(snapped(danger, .10), 1, 5)


func spawn_mob():
	var new_mob = preload("res://scenes/mob.tscn").instantiate()
	spawner.progress_ratio = randf()
	# implement scaling here. make knockback work first!
	
	new_mob.global_position = spawner.global_position
	new_mob.move_speed = 30
	new_mob.scalar = randf_range(1, clampf(danger_factor, 1, 3))

		
	
		


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

			
		
