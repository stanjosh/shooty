extends Node2D

@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var area_2d = $Area2D
var damaged_bodies : Array
var damage : float = 50


func _process(delta):
	$PointLight2D.energy -= 3.5 * delta
	pass

func _ready():
	$AudioStreamPlayer.play(.3)

func _on_animated_sprite_2d_animation_finished():
	queue_free()
	


func _on_area_2d_body_entered(body):
	
	if body.has_method("take_damage"):
		var area_damage = snapped(clampi(damage - global_position.distance_to(body.global_position), 0, damage), 1)
		if damage >= 2:
			var angle = body.global_position.angle_to_point(global_position)
			body.take_damage(area_damage, angle)
	pass # Replace with function body.
