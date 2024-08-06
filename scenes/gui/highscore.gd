extends Control
class_name HighScore
@onready var rich_text_label = $RichTextLabel


func _ready():
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request("https://stanj.link/highscores")

func _on_request_completed(_result, _response_code, _headers, body):
	rich_text_label.clear()
	if _response_code == OK:
		var json = JSON.parse_string(body.get_string_from_utf8())
		for row in json:
			rich_text_label.append_text("%s : %s \n" % [row["name"], row["score"]])
	else:
		rich_text_label.text = "Oops! Couldn't get the high scores! Spankings?"
