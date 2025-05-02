class_name SpawnWave extends Node2D

signal wave_complete(wave_number : int)

enum MobType {
	BAT,
	MEDIOID,
	TINY,
	RANDOM
}

var mobs = {
	MobType.BAT : preload("res://scenes/mobs/bat/bat.tscn"),
	MobType.MEDIOID : preload("res://scenes/mobs/medioid/medioid.tscn"),
	MobType.TINY : preload("res://scenes/mobs/tiny/tiny.tscn"),
}

@export var mobs_list : Array[MobType]

@onready var spawn_timer : Timer = Timer.new()
@onready var wait_timer : Timer = Timer.new()

@export var spawn_time : float : 
	set(value):
		spawn_timer.wait_time = value
@export var wait_time : float :
	set(value):
		wait_timer.wait_time = value

func spawn_enemy():
	var spawn_area = get_viewport_rect().grow(32)
	
	for mob : MobType in mobs_list:
		var spawn_point = randf() * spawn_area.end
		var new_mob : Mob = mobs[mob].instantiate()
		new_mob.global_position = spawn_point
		new_mob.strategy = Mob.MobStrategy.CHASE
		MapManager.current_map.add_child(new_mob)

func _input(event):
	if Input.is_action_just_pressed("cheat"):
		spawn_enemy()
