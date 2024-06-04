extends Mob



const HIT_MARKER = preload("res://scenes/effects/HitMarker.tscn")


var states : Dictionary = {}
var current_state : State
var current_health : float
var death_sprays : float

var display_damage_timer : float = 3
var scalar : float = 1

func _ready():
	
	if randf() < .09:
		max_health *= 4 * scalar
		scale = Vector2(scalar, scalar)
		player_damage *= 4 * scalar
	elif randf() < .08:
		move_speed *= scalar
		player_damage /= scalar
	
	current_health = max_health
	

		
func _physics_process(delta):
	melee_attack = false
	if global_position.distance_to(player.global_position) > 750:
		queue_free()
	elif global_position.distance_to(player.global_position) < 20:
		melee_attack = true
		velocity = Vector2(0, 0)
	else:
		velocity = global_position.direction_to(player.global_position) * move_speed
		velocity -= Vector2(move_speed * delta, move_speed * delta)
	animate()
	move_and_collide(velocity * delta)

func animate():
		var current_animation = "attack" if melee_attack else "idle"
		animated_sprite_2d.flip_h = false if velocity.x > 0 else true
		animated_sprite_2d.play(current_animation)

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
	
	
	const CORPSE = preload("res://scenes/mobs/corpse.tscn")
	var new_corpse = CORPSE.instantiate()
	new_corpse.global_position = global_position
	new_corpse.velocity = velocity
	new_corpse.scale = scale
	
	world.add_child(new_spray)
	world.add_child(new_corpse)
	

	queue_free()


