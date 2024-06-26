extends Node
 
class sound_info:
	var timer
	var resource_path
 
var recently_played_sounds = []
 
func _process(delta):
	for i in range(recently_played_sounds.size()-1, -1, -1):
		recently_played_sounds[i].timer -= delta
		if recently_played_sounds[i].timer <= 0.0:
			recently_played_sounds.remove_at(i)
 
func register_sound(_stream, _timer = 0.15):
	var new_sound_info = sound_info.new()
	new_sound_info.resource_path = _stream.resource_path
	new_sound_info.timer = _timer
	recently_played_sounds.append(new_sound_info)
 
func sound_was_recently_played(_stream):
	for my_sound_info in recently_played_sounds:
		if _stream.resource_path == my_sound_info.resource_path:
			return true
	 
	return false
