extends CharacterBody2D
class_name Mob

@onready var world = $".."
@onready var player = $"../player"
@export var max_health = 10

@export var initial_state : State
@export var player_damage = randf_range(5, 15)
@export var move_speed : float

const HIT_MARKER = preload("res://scenes/effects/HitMarker.tscn")
const DAMAGE_NUMBER = preload ("res://scenes/FloatingStatus.tscn")

var states : Dictionary = {}
var current_state : State
var current_health : float
var death_sprays : float
var is_alive : bool = true
var display_damage_timer : float = 3
var scalar : float = 1

func _ready():
	
	if randf() < .09:
		max_health *= 10 * scalar
		scale = Vector2(scalar, scalar)
		player_damage *= 4 * scalar
	elif randf() < .08:
		move_speed *= scalar
		player_damage /= scalar
	
	current_health = max_health
	

		
func _physics_process(delta):
	if global_position.distance_to(player.global_position) > 750:
		queue_free()
	velocity = global_position.direction_to(player.global_position) * move_speed
	move_and_collide(velocity * delta)


func take_damage(hit, vector):

	hit -= snapped(randf_range(-1, 1), 1)
	current_health -= hit
	
	
	var new_hit_marker = HIT_MARKER.instantiate()
	new_hit_marker.global_position = global_position
	world.add_child(new_hit_marker)
	

	var new_damage_number = DAMAGE_NUMBER.instantiate()
	new_damage_number.value = hit
	var rando_pos = snapped(randf_range(-8,8), 6)
	new_damage_number.global_position = Vector2(global_position.x + rando_pos, global_position.y)
	new_damage_number.vector = vector
	world.add_child(new_damage_number)
		
	if current_health <= 0:
		die(vector)

func die(vector):
	player.kill_shot()
	
	const DARK_SPRAY = preload("res://scenes/effects/dark_spray.tscn")
	var new_spray = DARK_SPRAY.instantiate()
	new_spray.global_position = global_position
	new_spray.rotation = vector
	new_spray.scale = scale
	
	
	const CORPSE = preload("res://scenes/corpse.tscn")
	var new_corpse = CORPSE.instantiate()
	new_corpse.global_position = global_position
	new_corpse.velocity = velocity
	new_corpse.scale = scale
	
	world.add_child(new_spray)
	world.add_child(new_corpse)
	

	queue_free()



