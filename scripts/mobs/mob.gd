extends CharacterBody2D
class_name Mob

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var world = $".."
@onready var player = $"../player"
@export var health = 10
@export var initial_state : State
@export var player_damage = randf_range(5, 15)
@export var move_speed : float

var states : Dictionary = {}
var current_state : State


func _ready():
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
	if current_state:
		current_state.Physics_Update(delta)
	var current_animation = ""
	if velocity.x == 0 and velocity.y == 0:
		current_animation = "idle"
	else:
		if velocity.x:
			current_animation = "x_walk"
			if velocity.x > 0:
				animated_sprite_2d.flip_h = false
			elif velocity.x < 0:
				animated_sprite_2d.flip_h = true
		if abs(velocity.y) > abs(velocity.x):
			if velocity.y > 0:
				current_animation = "down_walk"
			elif velocity.y < 0:
				current_animation = "up_walk"
	animated_sprite_2d.play(current_animation)
	move_and_collide(velocity * delta)

func take_damage(hit, vector):
	const BLOOD_SPRAY = preload("res://scenes/blood_spray.tscn")
	var new_spray = BLOOD_SPRAY.instantiate()
	new_spray.rotation = vector
	add_child(new_spray)
	health -= hit

	if health <= 0:
		health = 0
		die(vector)

func die(vector):
	const CORPSE = preload("res://scenes/corpse.tscn")
	const DEATH_SPRAY = preload("res://scenes/death_spray.tscn")
	var new_corpse = CORPSE.instantiate()
	var new_spray = DEATH_SPRAY.instantiate()
	new_spray.global_position = global_position
	new_spray.rotation = vector
	new_corpse.global_position = global_position
	new_corpse.velocity = velocity
	world.add_child(new_spray)
	world.add_child(new_corpse)
	player.kill_shot()
	queue_free()

