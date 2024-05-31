extends CharacterBody2D
class_name Mob

@onready var health_bar = $HealthBar
@onready var world = $".."
@onready var player = $"../player"
@export var max_health = 10

@export var initial_state : State
@export var player_damage = randf_range(5, 15)
@export var move_speed : float


var states : Dictionary = {}
var current_state : State
var current_health : float
var death_sprays : float
var is_alive : bool = true
var display_damage_timer : float = 3
var scalar : float = 1

func _ready():
	
	if randf() < .09:
		max_health *= scalar
		scale = Vector2(scalar, scalar)
		player_damage *= scalar
	elif randf() < .08:
		move_speed *= scalar
		player_damage /= scalar
	
	current_health = max_health
	health_bar.max_value = max_health
	for child in get_children():
		if child is State:
			child.player = player
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
			
	if initial_state:
		initial_state.Enter()
		current_state = initial_state
		
func _process(delta):

	if current_state:
		current_state.Update(delta)

func on_child_transition(state, new_state_name):

	if state != current_state:
		return
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	if current_state:
		current_state.Exit()
	
	new_state.Enter()
	current_state = new_state

func _physics_process(delta):
	health_bar.visible = true if current_health != max_health else false
	health_bar.value = current_health
	if current_state:
		current_state.Physics_Update(delta)
	move_and_collide(velocity * delta)

func take_damage(hit, vector):
	if current_health > 0: 
		hit -= snapped(randf_range(-1, 1), 1)
		current_health -= hit
		
		const HIT_MARKER = preload("res://scenes/HitMarker.tscn")
		var new_hit_marker = HIT_MARKER.instantiate()
		new_hit_marker.global_position = global_position
		world.add_child(new_hit_marker)
		
		const DAMAGE_NUMBER = preload ("res://scenes/FloatingStatus.tscn")
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
	
	const DARK_SPRAY = preload("res://scenes/dark_spray.tscn")
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



