extends Area2D

@export var survival_scene : PackedScene
@onready var map = get_node("/root/Game/World/Map")


@onready var survival_area : Area2D = survival_scene.instantiate()

func _ready():
	survival_area.global_position = global_position





func _on_body_entered(body):
	if overlaps_body(PlayerManager.player):
		map.add_child(survival_area)
		queue_free()
