extends Area2D

signal wake_up

const TINY = preload("res://scenes/mobs/tiny/tiny.tscn")
const MEDIOID = preload("res://scenes/mobs/medioid/medioid.tscn")
const BAT = preload("res://scenes/mobs/bat/bat.tscn")
@onready var mobs = $Mobs
var rect := RectangleShape2D.new()
var enemies = [TINY, MEDIOID, BAT]

@export var monster_capacity: float = 1

@onready var collision_shape_2d = $CollisionShape2D

func resize_area(size: Vector2):
	rect.extents = size - Vector2(Settings.TILE_SIZE.x * .5, Settings.TILE_SIZE.y * .5)
	collision_shape_2d.set_deferred("shape", rect)


func spawn_room():
	print("spawning")
	collision_shape_2d.shape.extents = Vector2(Settings.ROOM_SIZE - Vector2i(3, 3)) * Settings.TILE_SIZE / 2
	var spawn_capacity = monster_capacity
	var shape : RectangleShape2D = collision_shape_2d.shape
	var area = shape.extents
	while spawn_capacity > 0:
		var pos = shape.get_rect().get_center() + Vector2(randi_range(int(-area.x), int(area.x)), randi_range(int(-area.y), int(area.y)))
		var mob = spawn_mob(pos)
		add_child(mob)
		spawn_capacity -= mob.spawn_weight
	print(mobs.get_child_count())

func spawn_mob(pos):
	var mob : Mob = enemies.pick_random().instantiate().init(self, Mob.MobStrategy.LAZY, pos)
	return mob


func _on_body_entered(body):
	if body is Player:
		wake_up.emit()
