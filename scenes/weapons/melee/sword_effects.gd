extends Node2D
class_name MeleeWeaponEffect

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

var combo_step : int = 1
var sheath_countdown : float = .5
var sheathed : bool = true

func play():
	sheathed = false
	$Shing.pitch_scale = randf_range(0.9, 1.1)
	$Shing.play(.4)
	animated_sprite_2d.flip_v = true if randf() > .5 else false
	combo_step = wrapi(combo_step + 1, 1, 3)
	var anim_string = "slash%s" % combo_step
	animated_sprite_2d.play(anim_string)
	sheath_countdown = 1

func _physics_process(delta):
	if not sheathed and sheath_countdown <= 0:
		sheathed = true
		$sword_sheathed.play()
	else:
		sheath_countdown -= delta
