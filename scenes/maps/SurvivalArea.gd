extends Area2D
@onready var point_light_2d = $PointLight2D


signal spawns_done

var gradient_offset = 0
var active = false
var done = false

@onready var rect : Rect2 = $CollisionShape2D.shape.get_rect()
@onready var particle_radius = $CPUParticles2D.emission_sphere_radius
@onready var player : CharacterBody2D = get_node("/root/Game/World/player")

func _ready():
	for child in $Spawner.get_children():
		if child is SpawnWave:
			wave_list.append(child)

func _physics_process(delta):
	if active:
		if rect.size.y > particle_radius:
			particle_radius = clampf($CPUParticles2D.emission_sphere_radius + 1 * delta, particle_radius, rect.size.y)
		if gradient_offset < 0.7:
			activate_graphics(delta)
		if rect.get_center().distance_to(to_local(player.global_position)) > rect.get_area() / 2:
			player.take_damage(40 * delta, to_local(player.global_position).angle_to_point(rect.get_center()))
	elif done:
		if get_mobs() == false:
			explode(delta)



var wave_list : Array[SpawnWave]

func _process(_delta):
	$SpawnPath/SpawnPoint.progress_ratio = randf()

	
func activate():
	$CPUParticles2D.scale_amount_max = 0.5
	$CPUParticles2D.gravity = Vector2(0, -120)
	active = true
	begin_wave()


func begin_wave():
	if wave_list.size() >= 1:
		var wave = wave_list.pop_front()
		wave.wave_complete.connect(_on_wave_complete)
		wave.spawn_point = $SpawnPath/SpawnPoint
		wave.activate()
	else:
		active = false

func get_mobs():
	return true if get_overlapping_bodies().filter(func(body): return body is Mob).size() >= 1 else false

func explode(delta):
	var color := Color("White")
	gradient_offset -= 1 * delta
	var gradient : Gradient = point_light_2d.texture.gradient
	gradient.set_color(1, color)
	gradient.set_offset(1, gradient_offset)
	$CPUParticles2D.one_shot = true
	if gradient_offset <= 0 and not $CPUParticles2D.emitting:
		queue_free()

func activate_graphics(delta):
		gradient_offset = clampf(gradient_offset + 1 * delta, 0, 0.7)
		var gradient : Gradient = point_light_2d.texture.gradient
		gradient.set_offset(1, gradient_offset)

func _on_wave_complete():
	print("beginning wait period")
	$BetweenWaveTime.start()

func _on_between_wave_time_timeout():
	print("beginning next wave")
	begin_wave()

func _on_body_entered(body):
	if body is Player:
		activate()

func _on_spawns_done():
	active = false
	done = true
	print("done, waiting for mobs to die")
