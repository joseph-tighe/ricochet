extends MultiplayerSpawner

@export var network_player : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Spawn into the spawner's parent (the default spawn_path), not into the
	# spawner node itself.
	spawn_path = NodePath("..")

	# A custom spawn function lets us name the node after its peer and set the
	# authority *before* it enters the tree, which MultiplayerSynchronizer needs.
	if network_player != null:
		spawn_function = _spawn_custom

	# Connect on every peer; handlers no-op on clients.
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	if multiplayer.is_server():
		# The host player is part of the level scene.
		_apply_username(get_parent().get_node_or_null(str(multiplayer.get_unique_id())))
		# Peers may have connected before this level was loaded.
		for id in multiplayer.get_peers():
			if get_parent().get_node_or_null(str(id)) == null:
				spawn(id)

func _spawn_custom(data: Variant) -> Node:
	var id := int(data)
	var player: Node = network_player.instantiate()
	player.name = str(id)
	_set_authority(player, id)
	if id == multiplayer.get_unique_id():
		_apply_username(player)
	return player

func _on_peer_connected(id: int) -> void:
	if not multiplayer.is_server():
		return
	if get_parent().get_node_or_null(str(id)) == null:
		# Not during the multiplayer poll: adding a child there upsets the tree.
		spawn.call_deferred(id)

func _on_peer_disconnected(id: int) -> void:
	var player := get_parent().get_node_or_null(str(id))
	if player:
		player.queue_free()

func _set_authority(node: Node, id: int) -> void:
	node.set_multiplayer_authority(id)
	for child in node.get_children():
		_set_authority(child, id)

func _apply_username(player: Node) -> void:
	if player == null or MultiplayerHandler.username.is_empty():
		return
	var body := player.get_node_or_null("CharacterBody2D")
	if body != null:
		body.username = MultiplayerHandler.username
