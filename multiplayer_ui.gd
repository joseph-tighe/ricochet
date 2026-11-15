extends CanvasLayer

var _refresh_timer := 0.0

func _ready() -> void:
	# Running the level without a room (e.g. directly from the editor).
	if not multiplayer.has_multiplayer_peer():
		$Info.visible = false
		$Leave.visible = false
		return

	$Leave.pressed.connect(_on_leave_pressed)
	MultiplayerHandler.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peers_changed)
	multiplayer.peer_disconnected.connect(_on_peers_changed)
	_refresh()

func _process(delta: float) -> void:
	if not $Info.visible:
		return
	_refresh_timer += delta
	if _refresh_timer < 0.5:
		return
	_refresh_timer = 0.0
	_refresh()

func _refresh() -> void:
	var port := MultiplayerHandler.room_port
	var players := MultiplayerHandler.get_peer_count()
	var lines: Array[String] = []

	if MultiplayerHandler.is_host:
		lines.append("Player: %s   |   Host   |   Players: %d/%d" % [
			MultiplayerHandler.username, players, MultiplayerHandler.max_players
		])
		lines.append("Join at %s" % MultiplayerHandler.get_join_hint(port))
		lines.append("Waiting for players..." if players < 2 else "Someone joined.")
	else:
		var room_ip := MultiplayerHandler.connected_address
		if room_ip.is_empty():
			room_ip = MultiplayerHandler.room_address
		lines.append("Player: %s   |   Client   |   Players: %d" % [
			MultiplayerHandler.username, players
		])
		lines.append("Connected to %s:%d" % [room_ip, port])

	$Info.text = "\n".join(lines)

func _on_peers_changed(_id: int) -> void:
	_refresh()

func _on_leave_pressed() -> void:
	MultiplayerHandler.leave_room()

func _on_server_disconnected() -> void:
	MultiplayerHandler.leave_room()
