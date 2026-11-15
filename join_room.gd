extends Control

@onready var username_field: LineEdit = %Username
@onready var address_field: LineEdit = %Address
@onready var port_field: LineEdit = %Port
@onready var status_label: Label = %Status
@onready var join_button: Button = %JoinButton
@onready var create_button: Button = %CreateInstead
@onready var back_button: Button = %BackButton

var _connecting_since := -1
var _slow_hint_shown := false

func _ready() -> void:
	join_button.pressed.connect(_on_join_pressed)
	create_button.pressed.connect(_on_create_pressed)
	back_button.pressed.connect(_on_back_pressed)
	MultiplayerHandler.connection_failed.connect(_on_connection_failed)
	status_label.text = ""
	username_field.grab_focus()

func _process(_delta: float) -> void:
	if _connecting_since < 0 or _slow_hint_shown:
		return
	if Time.get_ticks_msec() - _connecting_since > 10000:
		_slow_hint_shown = true
		status_label.text = "Still connecting...\nCheck that:\n- the host is still on the Create Room screen (or in game),\n- you typed the host's computer name or IP (not 127.0.0.1),\n- the host allowed the game through Windows Firewall (UDP),\n- both computers are on the same network."

func _on_join_pressed() -> void:
	var player_name := username_field.text.strip_edges()
	if player_name.is_empty():
		_show_error("Please enter a username before joining a room.")
		username_field.grab_focus()
		return

	var address := address_field.text.strip_edges()
	if address.is_empty():
		address = MultiplayerHandler.DEFAULT_ADDRESS

	var port := int(port_field.text.strip_edges())
	if port < 1024 or port > 65535:
		_show_error("Enter a room port between 1024 and 65535.")
		return

	var err := MultiplayerHandler.join_room(player_name, address, port)
	if err != OK:
		_show_error("Could not start the connection (error %d)." % err)
		return

	join_button.disabled = true
	status_label.text = "Connecting to %s on port %d..." % [address, port]
	_connecting_since = Time.get_ticks_msec()
	_slow_hint_shown = false

func _on_connection_failed() -> void:
	_connecting_since = -1
	join_button.disabled = false
	_show_error("Could not reach the room. Check the address, port and the host's firewall.")

func _on_create_pressed() -> void:
	get_tree().change_scene_to_file("res://create_room.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main menu.tscn")

func _show_error(message: String) -> void:
	status_label.text = message
