extends Node2D


const LIGHTNING_BOLT = preload("res://scenes/effects/action_line.tscn")
@onready var world = get_node("/root/Game/World")
@export var speed : float = 50
@export var dropoff : float = 1
@export var user : CharacterBody2D
var direction : Vector2
var piercing : int = 10
var damage : int = 50

var lightning_targets : Array

func _ready():
	lightning_targets.push_front(global_position)
	$Area2D.global_position = get_global_mouse_position()
	lightning_targets.push_front(get_global_mouse_position())
	var zap = LIGHTNING_BOLT.instantiate()
	zap.lightning = lightning_targets
	world.add_child(zap)
	lightning_targets.clear()

func _physics_process(delta):
	var bodies = $Area2D.get_overlapping_bodies()
	if piercing > 0:
		if bodies:
			for body in bodies:
				bodies.shuffle()
				lightning_targets.push_front(body)
				piercing -= 1
	if lightning_targets:
		for target in lightning_targets:
			target.take_damage(damage / lightning_targets.size(), global_rotation)
		var zap = LIGHTNING_BOLT.instantiate()
		zap.lightning = lightning_targets.map(func(target): return target.global_position)
		world.add_child(zap)

	
	queue_free()
