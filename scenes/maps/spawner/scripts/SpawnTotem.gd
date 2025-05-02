extends Area2D

@export var survival_scene : PackedScene


@onready var survival_area : Area2D = survival_scene.instantiate()


func _ready():
	survival_area.global_position = global_position





func _on_body_entered(_body):
	if overlaps_body(PlayerManager.player):
		MapManager.current_map.call_deferred("add_child", survival_area)
		queue_free()
