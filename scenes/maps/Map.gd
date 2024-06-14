extends Node2D
class_name Map

@onready var player : CharacterBody2D = get_node("/root/Game/World/player")
@onready var camera : Camera2D = get_node("/root/Game/World/player/PositionalCamera")
@onready var outside_light = $OutsideLight
@onready var inside_light = $InsideLight



@export var camera_is_following : bool = false
@export var player_spawn : Marker2D
@export var sunlight : bool = false





var falling_mobs : Array[CharacterBody2D]
func _ready():

	outside_light.set_deferred("enabled", sunlight)
	inside_light.set_deferred("enabled", !sunlight)
	sunlight = !sunlight
	for mob in $Mobs.get_children():
		if mob is Mob:
			mob.player = player
			
	if player:
		if player_spawn:
			player.global_position = player_spawn.global_position
		if camera_is_following:
			camera.switch_to_following()
		else:
			if player_spawn:
				camera.current_screen = player_spawn.global_position
			camera.switch_to_positional( player.global_position )


func _on_camera_switch_positional_body_exited(body):
	camera.switch_to_positional( global_position )


func _on_camera_switch_follow_body_exited(body):
	camera.switch_to_following()


func _on_mine_slider_body_entered(body):
	if body is Mine:
		body.linear_damp = 0.8
		


func _on_mine_slider_body_exited(body):
	if body is Mine:
		body.linear_damp = 5.5








func _on_platform_switch_switched(value : bool):
	print(value)


func _on_light_changer_area_body_entered(body):
	inside_light.set_deferred("enabled", !sunlight)
	outside_light.set_deferred("enabled", sunlight)

func _on_light_changer_area_body_exited(body):
	set_deferred("sunlight", !sunlight)
	print(sunlight)
