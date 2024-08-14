extends Area2D
class_name MeleeWeaponEffect

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D

var combo_step : int = 1
var sheath_countdown : float = .5
var sheathed : bool = true
var heat_level : float = 0

func play() -> void:
	sheathed = false
	$Shing.pitch_scale = randf_range(0.9, 1.1)
	$Shing.play(.4)
	combo_step = wrapi(combo_step + 1, 1, 3)
	var anim_string = "slash%s" % combo_step
	animation_player.play(anim_string)
	sheath_countdown = 1


func _physics_process(delta):
	
	
	if not sheathed and sheath_countdown <= 0:
		sheathed = true
		$sword_sheathed.play()
	else:
		sheath_countdown -= delta
