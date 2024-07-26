extends Node2D



const ZAP_LINE = preload("res://scenes/effects/ZapLine.tscn")
@onready var hurtbox = $Hurtbox

@onready var ray_cast_2d = $RayCast2D

@export var speed : float = 820
@export var dropoff : float = .25
@export var heat_generated : float = 10
@export var piercing : int = 10
@export var damage : int = 50
@onready var zap_sound = $ZapSound

var num_targets : float = 0
var lightning_targets : Array
var zap
var zap_time : float = .015
var zap_timer : float = zap_time

func _ready():
	zap = ZAP_LINE.instantiate()
	get_parent().add_child(zap)
	var m_pos = get_global_mouse_position()
	look_at(m_pos)
	ray_cast_2d.target_position.y = global_position.distance_to(m_pos) * 1.2
	zap_sound.play()
	

	
func _physics_process(delta):
	zap_timer -= 1 * delta
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
	if ray_cast_2d.is_colliding():
		var target = ray_cast_2d.get_collider()
		if target is Mob:
			if !lightning_targets.has(target):
				lightning_targets.push_back(target)
				var body = ray_cast_2d.get_collider()
				global_position = body.global_position


	if lightning_targets.size() >= piercing or dropoff <= 0:
		for body in lightning_targets:
			if body is Mob:
				body.take_damage(snapped(damage / lightning_targets.size(), 1), Vector2.DOWN)
				zap.add_point(body.global_position)
		zap.add_point(global_position)

		zap.do_zap()
		queue_free()
	
	
	
	
	dropoff -= 1 * delta

func _on_hurtbox_body_entered(body):
	var target = hurtbox.get_overlapping_bodies().pick_random()
	if !lightning_targets.has(target):
		lightning_targets.push_back(target)
		zap_timer = zap_time
