extends Node2D

@onready var collision_shape_2d = $CollisionShape2D
@onready var off : Sprite2D = $Off
@onready var on : Sprite2D = $On
@onready var area_2d = $Area2D

@export var active : bool = false
@export var one_shot : bool = false
signal Switched

func _ready():
	if one_shot:
		area_2d.disconnect("body_exited", _on_area_2d_body_exited)
	if active:
		on.show()
		off.hide()
	else:
		off.show()
		on.hide()
		

func check_bodies():
	var bodies = area_2d.get_overlapping_bodies()
	if bodies:
		bodies = bodies.filter(func(body): return body is Mine or body is Player)
		return (bodies)

func _on_area_2d_body_entered(body):
	if check_bodies():
		on.visible = true
		off.visible = false
		active = true
		Switched.emit(active)
	if one_shot:
		area_2d.disconnect("body_entered", _on_area_2d_body_entered)


func _on_area_2d_body_exited(body):
	if not check_bodies():
		off.visible = true
		on.visible = false
		active = false
		Switched.emit(active)
