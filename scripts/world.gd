extends Node2D


func get_mobs() -> Array[CharacterBody2D]:
	return get_children().filter(func(child): return child is Mob)


 
