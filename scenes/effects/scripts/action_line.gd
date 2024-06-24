extends Node2D

@onready var line_2d = $Line2D

@onready var zap = $zap

var lightning

func _ready():

	if lightning:
		for target in lightning:
			zap.pitch_scale += randf() * .3
			zap.play()
			line_2d.add_point(target)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	modulate.a -= 5 * delta
	if modulate.a <= 0:
		queue_free()


