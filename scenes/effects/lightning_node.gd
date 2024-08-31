extends Area2D

var lightning : LightningBolt = LightningBolt.new(self)



func _process(delta: float) -> void:
	if has_overlapping_areas():
		lightning.update_points()



func _on_area_entered(area: Area2D) -> void:
	if !lightning:
		lightning = LightningBolt.new(self)
		lightning.node2 = get_overlapping_areas().pick_random()
		add_child(lightning)
