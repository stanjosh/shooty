extends RigidBody2D

@export var base_damage : float = 20
@onready var explosion_radius = $ExplosionRadius
const EXPLOSION = preload("res://scenes/explosion.tscn")

@onready var world = $"../../.."
@export var speed : float = 100
@export var fuse : float = 2.2


var player_damage : float = 2
var target_position

func _ready():

	pass

func explode():
	var new_splode = EXPLOSION.instantiate()
	new_splode.global_position = global_position
	new_splode.scale = Vector2(0.75, 0.75)
	world.add_child(new_splode)
	queue_free()

func _physics_process(delta):
	
	fuse -= 3 * delta
	if fuse <= 0:
		explode()
