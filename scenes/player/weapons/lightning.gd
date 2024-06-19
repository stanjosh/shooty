extends Area2D

const LIGHTNING_BOLT = preload("res://scenes/effects/action_line.tscn")
@onready var world = get_node("/root/Game/World")
@export var speed : float = 10
@export var dropoff : float = 1
@export var user : CharacterBody2D
var direction : Vector2
var piercing : int = 10
var damage : int = 50

var already_hit : Array[Node2D]

var lightning
var last_lightning_pos

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)
	lightning = LIGHTNING_BOLT.instantiate()
	lightning.first_position = global_position
	lightning.last_position = get_global_mouse_position()
	global_position = get_global_mouse_position()
	world.add_child(lightning)
	




func _on_body_entered(body):
	var targets = get_overlapping_bodies()
	
	for i in range(piercing):
		if targets:
			var target = targets.pop_front()
			targets.shuffle()
			zap(target)
	
	call_deferred("queue_free")





func zap(target):
	if target.has_method("take_damage"):
		lightning = LIGHTNING_BOLT.instantiate()
		target.take_damage(snapped(damage / piercing, 1), global_rotation)
		lightning.first_position = last_lightning_pos if last_lightning_pos else global_position
		lightning.last_position = target.global_position
		world.add_child(lightning)
		last_lightning_pos = target.global_position
		piercing -= 1
