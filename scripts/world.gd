extends Node2D

@onready var spawner = %spawner

@onready var player = $player

const INITIAL_SPAWNS : int = 20

@export var spawn_timer : float = .5
@export var max_spawns : int
@export var danger_factor : float = 0

var mobs : Array
var active_grenades : Array

const MAP_SIZE = Vector2(128, 128)
const LAND_CAP = 0.3

func _ready():
	generate_world()
	

func generate_world():
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	
	var cells : Array = []
	for x in MAP_SIZE.x:
		for y in MAP_SIZE.y:
			var tile = noise.get_noise_2d(x, y)
			if tile < LAND_CAP:
				cells.append(Vector2(x, y))
			
	$ground.set_cells_terrain_connect(0, cells, 0, 0)


func process_danger():
	var danger : float
	if danger_factor <= 0 :
		danger_factor = 0
	danger += clampf(1 - (100 / player.health), 0, 1)
	danger += player.combo_counter / 25
	danger_factor = player.attackers.size() + clampf(snapped(danger, .10), 1, 5)
	return danger


func spawn_mob():
	var new_mob = preload("res://scenes/mob.tscn").instantiate()
	spawner.progress_ratio = randf()
	new_mob.global_position = spawner.global_position
	new_mob.move_speed = 30
	new_mob.scalar = randf_range(1, clampf(danger_factor, 1, 3))
	add_child(new_mob)
	max_spawns  = INITIAL_SPAWNS + (2 * danger_factor)

func _physics_process(delta):
	process_danger()
	max_spawns = INITIAL_SPAWNS + (2 * danger_factor)
	spawn_timer -= 1 * delta
	
	var allowed_spawns = max_spawns - mobs.size()
	if spawn_timer <= 0 and allowed_spawns >= 1:
		spawn_mob()
	

func _process(delta):
	mobs = get_children().filter(func(child): return child is Mob)
	active_grenades = get_children().filter(func(child): return child is Grenade)
