extends Node2D
class_name Gun

@onready var gun_click = $gun_click
@onready var gun_fire = $gun_fire
@onready var target = global_position



var states : Dictionary = {}
var state_list : Array = []

@export var initial_state : State
var current_state : State = initial_state

var current_magazine : int

var shot_time : float = 0

func _ready():
	
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)

	if initial_state:
		initial_state.Enter()
		current_state = initial_state
		current_magazine = current_state.magazine

func _process(delta):
	if current_state:
		current_state.Update(delta)

func _physics_process(delta):
	shot_time -= current_state.fire_rate * delta * 100 
	target = get_global_mouse_position()
	look_at(target)
	if current_state:
		current_state.Physics_Update(delta)

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
	current_magazine = new_state.magazine

func shoot(delta):
	if current_magazine == 0:
		reload()
	elif current_state.reload.time_left == 0 and current_magazine > 0 and shot_time <= 0:
		const BULLET = preload("res://scenes/projectile.tscn")
		var new_bullet = BULLET.instantiate()
		gun_fire.play()
		new_bullet.global_position = %barrel.global_position
		new_bullet.global_rotation = %barrel.global_rotation + randf_range(0, current_state.accuracy)
		new_bullet.piercing = current_state.piercing
		new_bullet.damage = current_state.damage
		%barrel.add_child(new_bullet)
		current_magazine -= 1
		shot_time = 100

func switch_fire_mode():
	#match current_state.name.to_lower():
		#"burstfire":
			#current_state = states["automatic"]
		#"automatic":
			#current_state = states["semi"]
		#"semi":
			#current_state = states["burstfire"]
	var list = states.values()
	var index = list.find(current_state)
	var new_state = list[index - 1]
	current_state = new_state
	gun_click.play()
	current_magazine = clamp(current_magazine, 0, current_state.magazine)


func _on_reload_timeout():
	current_magazine = current_state.magazine
	gun_click.play()
	pass # Replace with function body.

func reload():
	if current_magazine < current_state.magazine and not current_state.reload.time_left:
		current_magazine = 0
		current_state.reload.start()
