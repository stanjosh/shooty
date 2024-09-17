@tool
extends Area2D

@onready var zap_sound: AudioStreamPlayer2D = $ZapSound

var lightning : LightningBolt = LightningBolt.new(self)


func _ready() -> void:
	add_child(lightning)

func _process(delta: float) -> void:
	if has_overlapping_areas():
		if !is_instance_valid(lightning) and randf() > 0.9:
			zap_sound.play()
			new_lightning()
			

func new_lightning() -> Node2D:
	if has_overlapping_areas():
		var target = get_overlapping_areas().pick_random()
		lightning = LightningBolt.new(target)
		add_child(lightning)
		return target
	return null
