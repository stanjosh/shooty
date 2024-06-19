extends Area2D

@export var survival_scene : PackedScene
@onready var player = get_node("/root/Game/World/player")
@onready var map = get_node("/root/Game/World/Map")
@onready var spawner = $Spawner

@onready var survival_area : Area2D = survival_scene.instantiate()

func _ready():
	survival_area.global_position = global_position



func _physics_process(delta):
	if overlaps_body(player):
		map.add_child(survival_area)
		queue_free()
