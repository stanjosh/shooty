extends Node
class_name Oauth2

var port : int = int(Env.vars.get("PORT", 0 ))
var binding : String = Env.vars.get("BINDING", "")
var client_id : String = Env.vars.get("CLIENT_ID", "")
var client_secret : String = Env.vars.get("CLIENT_SECRET", "")
var auth_server : String = Env.vars.get("AUTH_SERVER", "")
var token_req : String = Env.vars.get("TOKEN_REQ", "")


var redirect_server = TCPServer.new()
var token : String
var refresh_token : String
var user_info : Dictionary

signal token_authorized
signal token_error(error : String)
signal working
signal logged_out

func authorize():
	load_tokens()
	if !await validate_tokens():
		if !await refresh_tokens():
			get_auth_code()

func _init():
	port = int(Env.vars.get("PORT", 0 ))
	binding = Env.vars.get("BINDING", "")
	client_id = Env.vars.get("CLIENT_ID", "")
	client_secret = Env.vars.get("CLIENT_SECRET", "")
	auth_server = Env.vars.get("AUTH_SERVER", "")
	token_req = Env.vars.get("TOKEN_REQ", "")

func _ready():
	if load_tokens():
		authorize()
	set_process(false)

func _process(_delta):
	if redirect_server.is_connection_available():
		print("connection available")
		var connection = redirect_server.take_connection()
		var request = connection.get_string(connection.get_available_bytes())
		if request:
			print(request)
			var auth_code = request.split("&scope")[0].split("=")[1]
			prints("Received auth code")
			get_token_from_auth(auth_code)
			connection.put_data(HTML.new("res://scenes/gui/oauth2/authorized.html.txt").ascii())
			set_process(false)
	
func get_auth_code():
	set_process(true)
	redirect_server.listen(port, binding)
	if redirect_server.is_listening():
		prints("listening on", redirect_server.get_local_port())
	
	var uri_parts := [
		"client_id=%s" % client_id,
		"redirect_uri=http://%s:%s" % [binding, port],
		"response_type=code",
		"scope=https://www.googleapis.com/auth/userinfo.email"
	]
	
	var uri = auth_server + "?" + "&".join(uri_parts)
	print("Getting auth code from %s" % uri)
	var error = OS.shell_open(uri)
	if error != OK:
		push_error("Couldn't open: \"%s\". Error code: %s." % [uri, error])

func get_token_from_auth(auth_code):
	print("Getting token from auth")
	var body = "&".join([
		"code=%s" % auth_code, 
		"client_id=%s" % client_id,
		"client_secret=%s" % client_secret,
		"redirect_uri=http://%s:%s" % [binding, port],
		"grant_type=authorization_code"
	])
	var response : Dictionary = await _http_post(token_req, body)
	print("token request completed")
	print(response)
	if response.has("error"):
		push_error(response["error"], " : ", response["error_description"])
		return
	token = response["access_token"]
	refresh_token = response["refresh_token"]
	prints("token:", token, "refresh token:", refresh_token)
	user_info = await get_user_info()
	token_authorized.emit()
	save_tokens()

func refresh_tokens() -> bool:
	print("refreshing tokens")
	var body = "&".join([
		"client_id=%s" % client_id,
		"client_secret=%s" % client_secret,
		"refresh_token=%s" % refresh_token,
		"grant_type=refresh_token"
	])

	var response : Dictionary = await _http_post(token_req, body)
	print(response)
	if response.has("error"):
		push_warning(response["error"], " : ", response["error_description"])
		return false
	elif response.get("access_token"):
		token = response["access_token"]
		save_tokens()
		print("token refreshed")
		user_info = await get_user_info()
		token_authorized.emit()
		return true
	print("could not refresh tokens")
	return false
	
func validate_tokens() -> bool:
	print("validating token")
	var body = "access_token=%s" % token
	var response : Dictionary = await _http_post(token_req, body)
	print(response)
	if token and response.has("expiration") and int(response["expiration"]) > 0:
		print(response["expiration"])
		print("token is valid")
		user_info = await get_user_info()
		token_authorized.emit()
		return true
	print("invalid token")
	return false

func load_tokens() -> bool:
	print("Loading tokens")
	var file := FileAccess.open_encrypted_with_pass("user://token.dat", FileAccess.READ, Env.vars.get("TOKEN_KEY"))
	if file != null:
		var tokens = file.get_var()
		token = tokens.get("token")
		refresh_token = tokens.get("refresh_token")
		file.close()
		print("token loaded successfully")
		return true
	return false

func save_tokens():
	print("Saving tokens")
	var file = FileAccess.open_encrypted_with_pass("user://token.dat", FileAccess.WRITE, Env.vars.get("TOKEN_KEY"))
	if file != null:
		var tokens = {
			"token" : token,
			"refresh_token" : refresh_token
		}
		file.store_var(tokens)
		file.close()
	else:
		push_error("cannot write to user://token.dat")

func clear_tokens():
	user_info = {}
	DirAccess.remove_absolute("user://token.dat")
	logged_out.emit()

func get_user_info():
	working.emit()
	var url = "https://www.googleapis.com/oauth2/v3/userinfo?access_token=%s" % token
	var headers = [
		"Content-Type: application/x-www-form-urlencoded"
		]
	headers = PackedStringArray(headers)
	var _http_request = HTTPRequest.new()
	add_child(_http_request)
	var response_code = _http_request.request(url, headers, HTTPClient.METHOD_GET)
	if response_code == OK:
		var response = await _http_request.request_completed
		print(response[3].get_string_from_utf8())
		return JSON.parse_string(response[3].get_string_from_utf8())
	else:
		return {}


func _http_post(url: String, request_data: String = "") -> Dictionary:
	working.emit()
	var headers = [
		"Content-Type: application/x-www-form-urlencoded"
		]
	headers = PackedStringArray(headers)
	var _http_request = HTTPRequest.new()
	add_child(_http_request)
	var response_code = _http_request.request(url, headers, HTTPClient.METHOD_POST, request_data)
	if response_code == OK:
		var response = await _http_request.request_completed
		return JSON.parse_string(response[3].get_string_from_utf8())
	else:
		return {}


