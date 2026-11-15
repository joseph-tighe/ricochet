extends MultiplayerSpawner

@export var network_player : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# The spawner only replicates scenes it knows about. Register the player
	# scene so peers receive spawned players.
	if network_player != null:
		# Registered through the method because the property is "_spawnable_scenes".
		add_spawnable_scene(network_player.resource_path)

	# Spawn into the spawner's parent (the default spawn_path), not into the
	# spawner node itself.
	spawn_path = NodePath("..")

	# Connect on every peer; handlers no-op on clients.
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	# On clients, give each replicated player the authority of the peer it
	# belongs to (the node name is that peer's id).
	spawned.connect(_on_spawned)

	if multiplayer.is_server():
		# The host player is part of the level scene.
		_apply_username(get_parent().get_node_or_null(str(multiplayer.get_unique_id())))
		# Peers may have connected before this level was loaded.
		for id in multiplayer.get_peers():
			if get_parent().get_node_or_null(str(id)) == null:
				_spawn_player(id)

func _on_peer_connected(id: int) -> void:
	if not multiplayer.is_server():
		return
	_spawn_player(id)

func _on_peer_disconnected(id: int) -> void:
	var player := get_parent().get_node_or_null(str(id))
	if player:
		player.queue_free()

# Called on clients when the server replicates a spawned player.
func _on_spawned(node: Node) -> void:
	var id := str(node.name).to_int()
	if id > 0:
		_set_authority(node, id)
		if id == multiplayer.get_unique_id():
			_apply_username(node)

func _spawn_player(id: int) -> void:
	if network_player == null:
		return
	var player: Node = network_player.instantiate()
	player.name = str(id)
	_set_authority(player, id)
	# Add to spawn_path (parent) so the spawner replicates it to peers.
	# Deferred because the parent may still be setting up its children.
	get_parent().call_deferred("add_child", player)

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
