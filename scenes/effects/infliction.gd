extends Node2D
class_name Infliction

signal infliction_tick

@export var lifetime : float = 10
@export var visual_effect : CPUParticles2D
@export var period : float = 2
var infliction_timer : Timer

func _ready() -> void:
	infliction_timer = Timer.new()
	infliction_timer.wait_time = period
	infliction_timer.autostart = true
	infliction_timer.timeout.connect(activate)
	add_child(infliction_timer)
	
func activate():
	lifetime -= 1
	if lifetime == 0:
		queue_free()
