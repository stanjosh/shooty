extends Area2D


@onready var scene_lighting = $"../../SceneLighting"
@onready var light_changer_collider_shape : Shape2D = $LightChangerCollider.shape

@export var light_level_1 : float = .15
@export var light_level_2 : float = 1

func _physics_process(_delta):
	
	if overlaps_body(PlayerManager.player):
		var top = light_changer_collider_shape.get_rect().position
		var bottom = light_changer_collider_shape.get_rect().end
		var pos = clampf((to_local(PlayerManager.get_global_position()).y - bottom.y) / (top.y - bottom.y), 0, 1)
		scene_lighting.energy = lerp(light_level_1, light_level_2, -pos)	

