@tool
extends Line2D
class_name LightningBolt
const LIGHTNING_GRADIENT : Gradient = preload("res://scenes/effects/lightning_gradient.tres")
const LIGHTNING_PARTICLES = preload("res://scenes/effects/lightning_particles.tscn")
var node_2_pos : Vector2
var opacity : float = 1
var lifetime : float = 3
var particles : CPUParticles2D
var calc_points : PackedVector2Array
var final_goal : Vector2
var animation_timer : float = 0.0
var angle_var : float = 30.0
@export var shocks : int



func _init(_node_2_pos : Vector2, _width: float = 2, _shocks: int = randi()%10) -> void:
	
	node_2_pos = _node_2_pos
	width = _width
	shocks = _shocks

func _ready() -> void:

	default_color = LIGHTNING_GRADIENT.sample(randf())
	particles = LIGHTNING_PARTICLES.instantiate()
	particles.emission_points = points
	add_child(particles)
	particles.color = default_color
	particles.color_ramp = LIGHTNING_GRADIENT
	particles.emitting = true
	closed = false

func _process(delta: float) -> void:
	final_goal = to_local(node_2_pos) - to_local(global_position)
	lifetime -= delta
	opacity -= randf() * lifetime * delta
	width *= opacity
	modulate.a = opacity
	if shocks and animation_timer <= 0:
			shocks -= 1
			create_points()
			animation_timer = randf_range(-0, 0.02)
	if shocks <= 0:
		print("lightning died")
		queue_free()
	if !particles.emitting and lifetime < 0:
		queue_free()

func create_points():
	update_points()
	points = calc_points
	calc_points.clear()



func update_points():
	var curr_line_len = 0
	var start_point = to_local(global_position)
	var min_segment_size = max(Vector2().distance_to(final_goal)/20,10)
	var max_segment_size = min(Vector2().distance_to(final_goal)/30,40)
	calc_points.append(start_point)
	while(curr_line_len < Vector2().distance_to(final_goal)):
		var move_vector = start_point.direction_to(final_goal) * randf_range(min_segment_size,max_segment_size)
		var new_point = start_point + move_vector
		var new_point_rotated = start_point + move_vector.rotated(deg_to_rad(randf_range(-angle_var,angle_var)))
		calc_points.append(new_point_rotated)
		start_point = new_point
		curr_line_len = start_point.length()
		
	calc_points.append(final_goal)
