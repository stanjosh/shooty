extends Control

const PORT : int= 0
const BINDING := "127.0.0.1"
const CLIENT_ID := ""
const CLIENT_SECRET := ""
const AUTH_SERVER := ""
const TOKEN_REQ := ""


var redirect_server = TCPServer.new()
var redirect_uri = "http://%s:%s" % [BINDING, PORT]
var token
var refresh_token

signal token_received

func _ready():
	print("ready")
	set_process(false)

	
func _process(_delta):
	if redirect_server.is_connection_available():
		print("connection available")
		var connection = redirect_server.take_connection()
		var request = connection.get_string(connection.get_available_bytes())
		if request:
			
			var auth_code = request.split("&scope")[0].split("=")[1]
			prints("auth code", auth_code)
			get_token_from_auth(auth_code)
			set_process(false)
	
func _get_auth_code():
	set_process(true)
	
	redirect_server.listen(PORT, BINDING)
	if redirect_server.is_listening():
		prints("listening on", redirect_server.get_local_port())
	
	var uri_parts := [
		"client_id=%s" % CLIENT_ID,
		"redirect_uri=%s" % redirect_uri,
		"response_type=code",
		"scope=https://www.googleapis.com/auth/userinfo.email"
	]
	
	var uri = AUTH_SERVER + "?" + "&".join(uri_parts)
	print("getting %s" % uri)
	var error = OS.shell_open(uri)
	if error != OK:
		printerr("Couldn't open: \"%s\". Error code: %s." % [uri, error])
	else:
		prints("code", error)
	

func get_token_from_auth(auth_code):
	print("getting token from auth")

	var body_parts = [
		"code=%s" % auth_code, 
		"client_id=%s" % CLIENT_ID,
		"client_secret=%s" % CLIENT_SECRET,
		"redirect_uri=%s" % redirect_uri,
		"grant_type=authorization_code"
	]
	
	var body = "&".join(body_parts)
	_http_post(_on_token_request_completed, TOKEN_REQ, body)

	
func validate_token():
	if !token:
		return false
	var body = "access_token=%s" % token
	_http_post(_on_token_validation_completed, TOKEN_REQ + "info", body)


	
func _on_token_validation_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var expiration = JSON.parse_string(body.get_string_from_utf8())["expires_in"]
	if expiration and int(expiration) > 0:
		print(expiration)
		print("token is valid")
		token_received.emit()
	


func _on_token_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("token request completed")
	var response = JSON.parse_string(body.get_string_from_utf8())
	token = response["token"]
	refresh_token = response["refresh_token"]
	prints("token:", token, "refresh token:", refresh_token)
	#save_tokens()
	token_received.emit()

func _http_post(callback: Callable, url: String, request_data: String = "") -> void:
	var headers = [
		"Content-Type: application/x-www-form-urlencoded"
		]
	headers = PackedStringArray(headers)
	var _http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.connect("request_completed", callback, CONNECT_ONE_SHOT)
	var error = _http_request.request(TOKEN_REQ + "info", headers, HTTPClient.METHOD_POST, request_data)
	if error != OK:
		push_error("An error occurred in the HTTP request with ERR Code: %s" % error)

func _on_button_pressed():
	_get_auth_code()
