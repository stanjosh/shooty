extends Mob

@onready var line : Line2D = $Line2D



var point_distance = 5

var point_number = 15

var time : float

var point_index : int

func _ready():
	for x in range(0, point_number * point_distance, point_distance):
		line.add_point(Vector2(x, 0))
	
	return super._ready()

func _physics_process(delta):
	time += delta
	line.texture.noise.offset += Vector3(delta, 0, 0)
	print(position.distance_to(line.get_point_position(point_number -1)))
	if position.distance_to(line.get_point_position(point_number - 2)) > point_distance and \
		not state == MobState.DEAD or state == MobState.ATTACKING:
		line.add_point(position + get_slither(12, 2))
	if line.points.size() > point_number:
		line.remove_point(0)

	return super._physics_process(delta)

func get_slither(num1, num2):
	return (sin(time * num1) * num2) * velocity.normalized().rotated(deg_to_rad(90))

func die(vector):
	queue_free()
