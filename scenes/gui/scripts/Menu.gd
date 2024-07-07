extends Control
class_name MainMenu

var fullscreen : bool = false

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_options_pressed():
	fullscreen = !fullscreen
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	pass # Replace with function body.


func _on_exit_pressed():
	get_tree().quit()


func _on_dungeon_gen_pressed():
	MapManager.default_map = "testing"
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	


