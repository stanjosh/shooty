extends Control
class_name FloatMessage

const FLOATING_STATUS = preload("res://scenes/effects/floating_status.tscn")
var _message : Array[String]
var _body : Node2D
var _vector : Vector2

func _init(message : Array[String], body : Node2D, vector : Vector2 = Vector2.ZERO):
	_message = message
	_body = body
	_vector = vector

func _ready():
	float_message(_message, _body, _vector)

func float_message(message : Array[String], body, vector : Vector2 = Vector2.ZERO):
	print(message[0])
	var pos = get_global_transform_with_canvas().get_origin()
	var lines = message.size()
	for line in message:
		var status_msg = FLOATING_STATUS.instantiate()
		lines -= 1
		status_msg.position = Vector2(pos.x, pos.y - 8 * lines)
		status_msg.value = line
		status_msg.vector = vector
		status_msg.display_time.wait_time = 0.5 * lines
		body.call_deferred("add_child", status_msg)
	queue_free()
