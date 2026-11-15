extends CanvasLayer

func _ready() -> void:
	# Running the level without a room (e.g. directly from the editor).
	if not multiplayer.has_multiplayer_peer():
		$Info.visible = false
		$Leave.visible = false
		return

	var port := MultiplayerHandler.room_port
	var room_ip := MultiplayerHandler.get_local_ip()
	if not MultiplayerHandler.is_host:
		room_ip = MultiplayerHandler.room_address
		# Prefer the address actually connected to (resolves hostnames too).
		var enet := multiplayer.multiplayer_peer as ENetMultiplayerPeer
		if enet != null:
			var connected_ip: String = enet.get_peer_address(1)
			if not connected_ip.is_empty():
				room_ip = connected_ip

	var role := "Host" if MultiplayerHandler.is_host else "Client"
	$Info.text = "Player: %s   |   %s   |   Room: %s:%d" % [
		MultiplayerHandler.username, role, room_ip, port
	]
	$Leave.pressed.connect(_on_leave_pressed)
	MultiplayerHandler.server_disconnected.connect(_on_server_disconnected)

func _on_leave_pressed() -> void:
	MultiplayerHandler.leave_room()

func _on_server_disconnected() -> void:
	MultiplayerHandler.leave_room()
