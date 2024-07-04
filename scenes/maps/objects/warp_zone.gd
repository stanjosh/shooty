extends Area2D


@onready var world = get_node("/root/Game/World")


func _on_body_entered(body):
	if body is Player:
		$CollisionShape2D.set_deferred("disabled", true)
		MapManager.call_deferred("load_map", world, "random_dungeon")
		
