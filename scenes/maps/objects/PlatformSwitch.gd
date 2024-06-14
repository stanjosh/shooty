extends Node2D

@onready var off : Sprite2D = $Off
@onready var on : Sprite2D = $On
@onready var platform := $Platform
@onready var platform_collider := $Platform/PlatformCollider
@onready var switch := $Switch




@export var active : bool = false

signal Switched

func _ready():
	if active:
		on.show()
		off.hide()
	else:
		off.show()
		on.hide()
		

func check_bodies():
	var bodies = switch.get_overlapping_bodies()
	if bodies:
		bodies = bodies.filter(func(body): return body is Player)
		return (bodies)

func reset():
	active = false

func _on_area_2d_body_entered(body):
	if check_bodies():
		on.visible = true
		off.visible = false
		active = true
		Switched.emit(active)
		platform_collider.set_deferred("disabled", true)



