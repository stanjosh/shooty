extends Area2D

@export var recieved_item : PackedScene
@export var image : CompressedTexture2D

func _process(_delta):
	if image:
		$Sprite2D.texture = image
	for body in get_overlapping_bodies():
		if body is Player:
			Powerups.give_item.emit(recieved_item)
			queue_free()
