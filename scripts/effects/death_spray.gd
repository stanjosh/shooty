extends Node2D
class_name Spray
@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	var index = randi_range(1, 5)
	index = "%s" % index
	animated_sprite_2d.play(index)
	

