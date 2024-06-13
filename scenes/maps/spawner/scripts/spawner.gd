extends Node2D



var wave_list : Array[SpawnWave]

func _ready():
	for child in get_children():
		if child is SpawnWave:
			wave_list.append(child)
	begin_wave()

func _process(_delta):
	$SpawnPath/SpawnPoint.progress_ratio = randf()

func begin_wave():
	
	if wave_list:
		var wave = wave_list.pop_front()
		wave.wave_complete.connect(_on_wave_complete)
		wave.spawn_point = $SpawnPath/SpawnPoint
		wave.activate()
	else:
		print("waves completed")



func _on_wave_complete():
	print("beginning wait period")
	$BetweenWaveTime.start()

func _on_between_wave_time_timeout():
	print("beginning next wave")
	begin_wave()
