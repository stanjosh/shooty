extends RigidBody2D
class_name Grenade

@export var base_damage : float = 20
@onready var explosion_radius = $ExplosionRadius
const EXPLOSION = preload("res://scenes/explosion.tscn")

@onready var world = $"../../.."
@export var speed : float = 100


var player_damage : float = 2


func _ready():
	print(World.active_grenades)
	pass

func take_damage(damage, global_rotation):
	var new_splode = EXPLOSION.instantiate()
	new_splode.global_position = global_position
	new_splode.scale = Vector2(0.75, 0.75)
	World.add_child(new_splode)
	queue_free()

