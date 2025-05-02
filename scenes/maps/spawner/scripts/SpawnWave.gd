extends Node2D
class_name SpawnWave

const SPAWN_PARTICLES = preload("res://scenes/maps/spawner/spawn_particles.tscn")


@export_range(1, 10) var danger_level : float
@export_range(0.1, 1) var spawn_speed : float = 1
@export_group("enemy 1")
@export var enemy1 : PackedScene
@export_range(1, 100) var enemy1_number : int

@export_group("enemy 2")
@export var enemy2 : PackedScene
@export_range(1, 100) var enemy2_number : int

@export_group("enemy 3")
@export var enemy3 : PackedScene
@export_range(1, 100) var enemy3_number : int

signal wave_complete
var enemy_array : Array[PackedScene]
var spawn_point : PathFollow2D
@onready var spawn_timer : Timer


func activate():
	if enemy1:
		var enemy1_array : Array = []
		enemy1_array.resize(enemy1_number)
		enemy1_array.fill(enemy1)
		enemy_array.append_array(enemy1_array)
	if enemy2:
		var enemy2_array : Array = []
		enemy2_array.resize(enemy2_number)
		enemy2_array.fill(enemy2)
		enemy_array.append_array(enemy2_array)
	if enemy3:
		var enemy3_array : Array = []
		enemy3_array.resize(enemy3_number)
		enemy3_array.fill(enemy3)
		enemy_array.append_array(enemy3_array)
	enemy_array.shuffle()
	spawn_timer = Timer.new()
	spawn_timer.connect("timeout", _on_spawn_timer_timeout)
	spawn_timer.wait_time = spawn_speed
	spawn_timer.autostart = true
	add_child(spawn_timer)
	spawn_timer.start()
	print(spawn_timer.wait_time, " ", spawn_timer.time_left)
	

func _on_spawn_timer_timeout():

	if enemy_array:
		var enemy = enemy_array.pop_front().instantiate()
		var particles = SPAWN_PARTICLES.instantiate()
		particles.global_position = spawn_point.global_position
		enemy.global_position = spawn_point.global_position
		enemy.difficulty_scalar = danger_level
		enemy.strategy = Mob.MobStrategy.CHASE
		MapManager.current_map.add_child(particles)
		MapManager.current_map.add_child(enemy)
	else:
		spawn_timer.stop()
		print("wave complete")
		wave_complete.emit()
