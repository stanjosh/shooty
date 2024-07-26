extends Node2D

@onready var animation_player = $AnimationPlayer

var open : bool = false

func _on_interactable_area_interacted(_player):
	animation_player.play("unlock")
	open = true

