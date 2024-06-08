extends Area2D

@export var recieved_item : PackedScene

func _process(delta):
	for body in get_overlapping_bodies():
		if body is Player:
			Powerups.give_item.emit(recieved_item)
			queue_free()
