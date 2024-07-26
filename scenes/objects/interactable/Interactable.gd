extends Area2D
class_name Interactable

signal interacted

func interact(player : Player):
	interacted.emit(player)

func _on_body_entered(body):
	if body is Player:
		var button = InputMap.action_get_events("interact")[0].as_text()
		UIManager.float_message(["press [%s] to open" % button], body.global_position)

