@tool
extends Line2D
class_name LightningBolt
const LIGHTNING_GRADIENT : Gradient = preload("res://scenes/effects/lightning_gradient.tres")
const LIGHTNING_PARTICLES = preload("res://scenes/effects/lightning_particles.tscn")
var node_2 : Node2D
var opacity : float = 1

var particles : CPUParticles2D
var calc_points : PackedVector2Array
var final_goal : Vector2
var animation_timer : float = 0.0
var angle_var : float = 30.0




func _init(_node_2 : Node2D, _width: float = 2) -> void:
	
	node_2 = _node_2
	width = _width


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
	if !is_instance_valid(node_2):
		queue_free()
		return
	final_goal = to_local(node_2.global_position) - to_local(global_position)

	opacity -= delta
	width *= opacity
	modulate.a = opacity
	animation_timer -= delta
	if animation_timer <= 0:
		create_points()
		animation_timer = randf_range(0.01, 0.03)


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
