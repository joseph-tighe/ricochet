extends Node

func _ready() -> void:
	var err := MultiplayerHandler.create_room("HostTest", 42123, 2)
	print("PROBE_HOST create_room err=", err, " hint=", MultiplayerHandler.get_join_hint(42123))
