extends Area2D



signal spawns_done

@onready var point_light_2d = $PointLight2D
@onready var rect : Rect2 = $CollisionShape2D.shape.get_rect()
@onready var particle_radius = $CPUParticles2D.emission_sphere_radius
@onready var player : CharacterBody2D = PlayerManager.player
@onready var spawner = $Spawner

var gradient_offset = 0
var alpha_offset = 0
var active = true
var wave_list : Array[SpawnWave]

func _ready():
	for child in spawner.get_children():
		if child is SpawnWave:
			wave_list.append(child)
	active = true
	begin_wave()


func _physics_process(delta):
	if active:
		if gradient_offset < 0.7:
			activate_graphics(delta)
		if rect.get_center().distance_to(to_local(player.global_position)) > rect.get_area() / PI:
			player.take_damage(40 * delta, to_local(player.global_position).angle_to_point(rect.get_center()))
	elif not PlayerManager.player.is_alive or not get_mobs() and not wave_list:
		close_area(delta)
	

func _process(_delta):
	$SpawnPath/SpawnPoint.progress_ratio = randf()

func close_area(delta):
	var gradient : Gradient = point_light_2d.texture.gradient
	gradient_offset = clampf(gradient_offset - 1 * delta, 0, 0.8)
	gradient.set_offset(1, gradient_offset)
	gradient.set_offset(2, gradient_offset + .03)
	$CPUParticles2D.explosiveness = 1
	$CPUParticles2D.one_shot = true
	if gradient_offset <= 0 and not $CPUParticles2D.emitting:
		queue_free()

func begin_wave():
	if get_mobs():
		$BetweenWaveTime.start()
	elif wave_list.size() >= 1:
		var wave = wave_list.pop_front()
		wave.wave_complete.connect(_on_wave_complete)
		wave.spawn_point = $SpawnPath/SpawnPoint
		wave.activate()
	else:
		active = false

func get_mobs():
	return true if get_overlapping_bodies().filter(func(body): return body is Mob).size() >= 1 else false
	

func activate_graphics(delta):
		particle_radius = point_light_2d.get_height()
		gradient_offset = clampf(gradient_offset + 1 * delta, 0, 0.9)
		var gradient : Gradient = point_light_2d.texture.gradient
		gradient.set_offset(1, gradient_offset)
		gradient.set_offset(2, gradient_offset + .03)

func _on_wave_complete():
	print("beginning wait period")
	$BetweenWaveTime.start()

func _on_between_wave_time_timeout():
	print("beginning next wave")
	begin_wave()

func _on_spawns_done():
	active = false
	print("done, waiting for mobs to die")
