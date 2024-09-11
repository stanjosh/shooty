extends Mob

@onready var sprite2d : Sprite2D = %Sprite2D

@export_category("Special Attack")
var copies_left: int =  2

func _ready():
	add_to_group("tiny")
	sprite2d.texture = sprite2d.texture.duplicate(true)
	return super._ready()

func special_attack(_delta) -> MobState:
	take_damage(max_health, Vector2.ZERO, 140)
	return MobState.CHASING

func take_damage(hit, vector: Vector2, extra_force: float = 0):
	if copies_left:
		var new_copy := self.duplicate()
		new_copy.strategy = MobStrategy.CHASE
		new_copy.original_pos = original_pos
		new_copy.copies_left = copies_left - 1
		new_copy.scale = scale * 0.75
		new_copy.max_health = health * 0.50
		new_copy.move_speed = move_speed * 1.5
		new_copy.global_position = global_position + Vector2(randi_range(-2, 2), randi_range(-2, 2))
		new_copy.chase_timer = chase_time
		new_copy.cry_played = true
		get_parent().call_deferred("add_child", new_copy)
	return super.take_damage(hit, vector, extra_force)
