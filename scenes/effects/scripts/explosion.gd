extends Node2D

@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var area_2d = $Area2D
var damaged_bodies : Array
var damage : int = 120


func _process(delta):
	if $PointLight2D.energy > 0:
		$PointLight2D.energy -= 3.5 * delta
	pass

func _ready():
	$AudioStreamPlayer.play(.3)

func _on_animated_sprite_2d_animation_finished():
	queue_free()
	


func _on_area_2d_body_entered(body):

	if body.has_method("take_damage"):
		var area_damage : int = clampi(snapped(damage - global_position.distance_to(body.global_position), 1), 0, damage)
		if damage >= 2:
			var angle = global_position.angle_to_point(body.global_position)
			body.take_damage(area_damage, angle)
	#if body is BloodSpray:
		#body.queue_free()

