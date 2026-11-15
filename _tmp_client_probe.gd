extends Node

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	var err := MultiplayerHandler.join_room("ClientTest", "localhost", 42123)
	print("PROBE_CLIENT join_room err=", err, " resolved=", MultiplayerHandler.room_address)
