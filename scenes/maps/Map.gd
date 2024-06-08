extends Node2D
class_name Map

@onready var player : CharacterBody2D = get_node("/root/Game/World/player")

func _ready():
	if $Mobs:
		for mob in $Mobs.get_children():
			if mob is Mob:
				mob.player = player
