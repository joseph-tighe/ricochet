extends CanvasLayer

func _ready() -> void:
	# Running the level without a room (e.g. directly from the editor).
	if not multiplayer.has_multiplayer_peer():
		$Info.visible = false
		$Leave.visible = false
		return

	var role := "Host" if MultiplayerHandler.is_host else "Client"
	$Info.text = "Player: %s   |   %s   |   port %d" % [
		MultiplayerHandler.username, role, MultiplayerHandler.room_port
	]
	if MultiplayerHandler.is_host:
		$Info.text += "   |   others join with %s:%d" % [
			MultiplayerHandler.get_local_ip(), MultiplayerHandler.room_port
		]
	$Leave.pressed.connect(_on_leave_pressed)
	MultiplayerHandler.server_disconnected.connect(_on_server_disconnected)

func _on_leave_pressed() -> void:
	MultiplayerHandler.leave_room()

func _on_server_disconnected() -> void:
	MultiplayerHandler.leave_room()
