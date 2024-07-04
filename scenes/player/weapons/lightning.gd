extends Node2D



const ZAP_LINE = preload("res://scenes/effects/ZapLine.tscn")
@onready var hurtbox = $Hurtbox

@onready var ray_cast_2d = $RayCast2D

@export var speed : float = 120
@export var dropoff : float = .25
@export var heat_generated : float = 10
@export var piercing : int = 10
@export var damage : int = 50
@onready var zap_sound = $ZapSound

var lightning_targets : Array

var target_position : Vector2

func _ready():
	target_position = get_global_mouse_position()
	zap_sound.play()

	
func _physics_process(delta):
	dropoff -= 1 * delta
	ray_cast_2d.target_position.y = global_position.distance_to(get_global_mouse_position())
	if ray_cast_2d.is_colliding():
		if ray_cast_2d.get_collider() is Mob:
			var body_position = ray_cast_2d.get_collider().global_position
			hurtbox.global_position = body_position
	
	if dropoff <= 0:
		queue_free()
