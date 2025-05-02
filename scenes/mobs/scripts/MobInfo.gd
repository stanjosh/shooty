class_name MobInfo
extends Resource



@export_category("Spawn")
@export_range(0, 1) var spawn_weight : float

@export_category("Movement")
@export var chase_time : float = 3
@export var move_speed : float
@export var acceleration : float = .2
@export var wander_distance : float = 10
@export var inertia : float = 10
@export var flying : bool = false

@export_category("Death")
@export var max_health : int
@export var bleeds : bool = false
@export var death_particles : bool = true
@export var xp_value : int = 0
@export var drops_items : Array[ItemData]

@export_category("Attack")
@export_range(20, 100) var attack_distance : int = 20
@export var special_cooldown: float = 2
@export var player_damage = randf_range(1, 7)
