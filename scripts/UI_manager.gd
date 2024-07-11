extends Node


signal update_hud(element_name, value, max_value)
signal refresh_interface(target)
signal update_stats(k, v)
signal pause_game
signal game_over



const FLOATING_STATUS = preload("res://scenes/effects/floating_status.tscn")
func float_message(message : Array[String], global_position, vector : Vector2 = Vector2.ZERO):
	var lines = message.size()
	for line in message:
		var status_msg = FLOATING_STATUS.instantiate()
		lines -= 1
		status_msg.position = global_position
		status_msg.position = Vector2(global_position.x, global_position.y - 8 * lines)
		status_msg.value = line
		status_msg.vector = vector
		call_deferred("add_child", status_msg)

func _input(event):
	if event.is_action_pressed("pause"):
		pause_game.emit()
