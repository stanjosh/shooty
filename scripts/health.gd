extends Node2D

@onready var health_pack = $HealthPack
const FLOATING_STATUS = preload("res://scenes/FloatingStatus.tscn")
@onready var world = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_health_pack_body_entered(body):
	var new_status = FLOATING_STATUS.instantiate()
	new_status.global_position = body.global_position
	new_status.modulate.g = 255
	new_status.modulate.r = 0
	new_status.modulate.b = 0
	new_status.scale = Vector2(2, 2)
	new_status.value = 20
	world.add_child(new_status)
	queue_free()
	pass # Replace with function body.
