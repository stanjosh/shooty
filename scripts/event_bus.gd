extends Node
class_name EventLog

var event_log : Array[Entry]

class Entry:
	var entity : Node2D
	var description : String
	func _init(_entity: Node2D, _description: String) -> void:
		entity = _entity
		description = _description
		
func add(entity: Node2D, description: String) -> void:
	event_log.push_back(Entry.new(entity, description))
