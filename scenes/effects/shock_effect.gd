extends Infliction

@onready var area_2d: Area2D = $Area2D
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D

func _ready() -> void:
	area_2d.add_to_group("lightnings", true)

	return super._ready()
	
func activate():
	get_parent().take_damage(randi_range(1, 3), Vector2.UP, -10)
	if randf() > 0.5:
		var target : Node2D
		if area_2d.has_overlapping_bodies():
			target = area_2d.get_overlapping_bodies().pick_random()
			target.add_child(LightningBolt.new(self, 3, 3))
			reparent(target)
	return super.activate()
