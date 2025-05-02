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
			print("overlaps")
			target = area_2d.get_overlapping_bodies().pick_random()
			target.add_child(LightningBolt.new(global_position))
			reparent(target)
	else:
		path_follow_2d.progress_ratio = randf()
		add_child(LightningBolt.new(path_follow_2d.global_position))
	return super.activate()
