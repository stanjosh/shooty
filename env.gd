extends Node

class_name DotEnv
var vars : Dictionary = {}


func _init():
	var file := FileAccess.get_file_as_string("res://.env")
	if(!file):
		push_warning("no env vars found")
		return

	var file_lines : PackedStringArray = file.split("\r\n")
	
	for line in file_lines:
		var env_var = line.split("=");
		if(env_var.size() == 2):
			vars[env_var[0]] = env_var[1]
	print(vars)

func get_var(var_name : String) -> String:
	return vars.get(var_name, "")
