extends Node

signal update_hud(element_name, value, max_value)

const FLOATING_STATUS = preload("res://scenes/effects/FloatingStatus.tscn")
var stats : Dictionary

func float_message(message : Array[String], global_position, vector : float = 1):
	var lines = message.size()
	for line in message:
		var status_msg = FLOATING_STATUS.instantiate()
		lines -= 1
		status_msg.position = global_position
		status_msg.position = Vector2(global_position.x, global_position.y - 8 * lines)
		status_msg.value = line
		status_msg.vector = vector
		call_deferred("add_child", status_msg)
