@tool
extends Node2D

@onready var end_point: Marker2D = $EndPoint
@onready var animation_timer: float = 0


#var min_segment_size: int
#var max_segment_size: int
var final_goal : Vector2
var calc_points : Array = []

@export var angle_var : float = 15.0
@export var emitting : bool = true :
	set(value):
		emitting = value
		shocks_left = shocks if emitting else 0
@export var one_shot : bool = false
@export var bolts : int = 1
@export var shocks : int = 3
@export var colors : Gradient = Gradient.new()

var shocks_left : int = 3

func _ready():
	shocks_left = shocks
	animation_timer = randf()
	

func _physics_process(delta: float) -> void:
	final_goal = end_point.global_position - global_position 
	animation_timer -= .15 * delta
	if one_shot and shocks_left < 1:
		emitting = false
	if emitting \
	and animation_timer <= 0 \
	and randf() > .7 and shocks_left > 0:
		shocks_left -= 1
		for i in range(bolts):
			create_points()

func clear_points():
	calc_points.clear()
	

func create_points():
	update_points()
	var new_bolt = LightningBolt.new()
	new_bolt.points = calc_points
	new_bolt.default_color = colors.sample(randf())
	add_child(new_bolt)
	calc_points.clear()
	animation_timer = randf_range(-0, 0.02)


func update_points():
	final_goal = end_point.global_position - global_position 
	var curr_line_len = 0
	var start_point = global_position
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
