extends Control

@onready var username_field: LineEdit = %Username
@onready var port_field: LineEdit = %Port
@onready var max_players_field: SpinBox = %MaxPlayers
@onready var status_label: Label = %Status
@onready var local_ip_label: Label = %LocalIp
@onready var create_button: Button = %CreateButton
@onready var join_button: Button = %JoinInstead
@onready var back_button: Button = %BackButton

func _ready() -> void:
	create_button.pressed.connect(_on_create_pressed)
	join_button.pressed.connect(_on_join_pressed)
	back_button.pressed.connect(_on_back_pressed)
	port_field.text_changed.connect(_on_port_changed)
	status_label.text = ""
	username_field.grab_focus()
	_refresh_ip_hint()

func _refresh_ip_hint() -> void:
	var port := port_field.text.strip_edges().to_int()
	if port <= 0:
		port = MultiplayerHandler.DEFAULT_PORT
	local_ip_label.text = "Other computers join with: %s" % MultiplayerHandler.get_join_hint(port)

func _on_port_changed(_text: String) -> void:
	_refresh_ip_hint()

func _on_create_pressed() -> void:
	var player_name := username_field.text.strip_edges()
	if player_name.is_empty():
		_show_error("Please enter a username before creating a room.")
		username_field.grab_focus()
		return

	var port := int(port_field.text.strip_edges())
	if port < 1024 or port > 65535:
		_show_error("Enter a room port between 1024 and 65535.")
		return

	var err := MultiplayerHandler.create_room(player_name, port, int(max_players_field.value))
	if err != OK:
		_show_error("Could not create the room (error %d). Try another port." % err)

func _on_join_pressed() -> void:
	get_tree().change_scene_to_file("res://join_room.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main menu.tscn")

func _show_error(message: String) -> void:
	status_label.text = message
