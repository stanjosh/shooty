extends Area2D

@onready var player :CharacterBody2D = get_node("/root/Game/World/player")
@onready var scene_lighting = $"../../SceneLighting"
@onready var light_changer_collider_shape : Shape2D = $LightChangerCollider.shape



func _physics_process(delta):
	
	if overlaps_body(player):
		var top = light_changer_collider_shape.get_rect().position
		var bottom = light_changer_collider_shape.get_rect().end
		var pos = clampf((to_local(player.global_position).y - bottom.y) / (top.y - bottom.y), 0, 1)
		scene_lighting.energy = lerp(.15, 1.0, -pos)	
