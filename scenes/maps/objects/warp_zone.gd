@tool
extends Area2D


var map : String 

func _get_property_list() -> Array:
	return [
		{
			name = "map",
			type = TYPE_STRING,
			hint = PROPERTY_HINT_ENUM,
			hint_string = ','.join(PackedStringArray(MapManager.maps.keys())),
			usage = PROPERTY_USAGE_DEFAULT,
		},
	]

func _get_configuration_warnings():
	if !map:
		return ["Need a Map object to transition to."]

func _on_body_entered(body):
	if body is Player:
		$CollisionShape2D.set_deferred("disabled", true)
		MapManager.call_deferred("load_map", "random_dungeon")

