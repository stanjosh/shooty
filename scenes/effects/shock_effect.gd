extends Infliction


@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var lightning_node: Area2D = $LightningNode

func _ready() -> void:

	return super._ready()
	
func activate():
	get_parent().take_damage(randi_range(1, 3), Vector2.UP, -10)
	if randf() > 0.5:
		var target = lightning_node.new_lightning()
		if target != null and target is Mob:
			reparent(target)
	return super.activate()
