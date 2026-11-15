extends Node

const DEFAULT_PORT := 42069
const DEFAULT_ADDRESS := "127.0.0.1"
const GAME_SCENE := "res://multiplayer lvl.tscn"
const MENU_SCENE := "res://main menu.tscn"

signal connection_failed
signal server_disconnected

var peer: ENetMultiplayerPeer
var username := ""
var is_host := false
var room_port := DEFAULT_PORT
var room_address := DEFAULT_ADDRESS
var connected_address := ""
var max_players := 2

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

# Host a room. Returns OK, or an error code if the port could not be opened.
func create_room(player_name: String, port: int = DEFAULT_PORT, players: int = 2) -> Error:
	_clear_peer()
	username = player_name.strip_edges()
	is_host = true
	room_port = port
	room_address = get_local_ip()
	max_players = players

	peer = ENetMultiplayerPeer.new()
	# Listen on every adapter (Wi-Fi, Ethernet, ...), not just loopback.
	peer.set_bind_ip("*")
	# max_players counts the host, but create_server expects a client count.
	var err := peer.create_server(port, maxi(1, players - 1))
	if err != OK:
		peer = null
		print("[multiplayer] could not host on port %d (error %d)" % [port, err])
		return err

	multiplayer.multiplayer_peer = peer
	print("[multiplayer] hosting on port %d - others join with %s" % [port, get_join_hint(port)])
	_load_game()
	return OK

# Join a room. The level is loaded once the server accepts the connection.
func join_room(player_name: String, address: String, port: int = DEFAULT_PORT) -> Error:
	_clear_peer()
	username = player_name.strip_edges()
	is_host = false
	room_port = port

	# Resolve names to IPv4 first: ENet may otherwise pick IPv6 and fail.
	var resolved := resolve_ipv4(address)
	room_address = resolved
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_client(resolved, port)
	if err != OK:
		peer = null
		print("[multiplayer] could not start connecting to %s:%d (error %d)" % [resolved, port, err])
		return err

	multiplayer.multiplayer_peer = peer
	print("[multiplayer] connecting to %s:%d (typed: %s)" % [resolved, port, address])
	return OK

func leave_room() -> void:
	_clear_peer()
	is_host = false
	get_tree().change_scene_to_file(MENU_SCENE)

# Best guess at the address other machines on the network should connect to.
func get_local_ip() -> String:
	var ips := get_local_ips()
	if ips.is_empty():
		return "127.0.0.1"
	return ips[0]

# IPv4 addresses that are usable on the local network.
func get_local_ips() -> Array[String]:
	const SKIP_INTERFACES := [
		"loopback", "bluetooth", "virtualbox", "vmware", "hyper-v", "vethernet",
		"wsl", "docker", "hamachi", "zerotier", "tailscale", "tap", "tun",
	]
	var ips: Array[String] = []
	for iface in IP.get_local_interfaces():
		var friendly := str(iface.get("friendly", "")).to_lower()
		var skipped := false
		for hint in SKIP_INTERFACES:
			if friendly.contains(hint):
				skipped = true
				break
		if skipped:
			continue
		for address in iface.get("addresses", []):
			var ip := str(address)
			if ip.contains(":") or ip.begins_with("127.") or ip.begins_with("169.254."):
				continue
			if not ips.has(ip):
				ips.append(ip)
	return ips

# Computer name, which other machines on the same LAN can often use instead of
# the IP (Windows name resolution).
func get_hostname() -> String:
	var name := OS.get_environment("COMPUTERNAME").strip_edges()
	if name.is_empty():
		name = OS.get_environment("HOSTNAME").strip_edges()
	return name

# Text the host can read out, e.g. "YOUR-PC:42069  (or 192.168.1.42:42069)".
func get_join_hint(port: int) -> String:
	var ip := get_local_ip()
	var computer_name := get_hostname()
	if computer_name.is_empty() or computer_name == ip:
		return "%s:%d" % [ip, port]
	return "%s:%d  (or %s:%d)" % [computer_name, port, ip, port]

# Turn a typed computer name into an IPv4 address. ENet can otherwise resolve
# a name to IPv6, which is often unreachable on a home network.
func resolve_ipv4(address: String) -> String:
	var typed := address.strip_edges()
	if typed.is_empty() or typed.is_valid_ip_address():
		return typed
	for ip in IP.resolve_hostname_addresses(typed, IP.TYPE_IPV4):
		if ip.contains("."):
			return ip
	return typed

# Host plus every connected client.
func get_peer_count() -> int:
	if not multiplayer.has_multiplayer_peer():
		return 0
	return multiplayer.get_peers().size() + 1

# Remote address of a peer, for log lines and the HUD.
func describe_peer(id: int) -> String:
	if not multiplayer.has_multiplayer_peer():
		return ""
	var enet := multiplayer.multiplayer_peer as ENetMultiplayerPeer
	if enet == null:
		return ""
	if enet.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		return ""
	# The host has no ENet peer entry for itself.
	if is_host and id == multiplayer.get_unique_id():
		return ""
	# get_peer() logs an engine error for unknown ids, so filter them out.
	if id != 1 and not multiplayer.get_peers().has(id):
		return ""
	var enet_peer := enet.get_peer(id)
	if enet_peer == null:
		return ""
	return enet_peer.get_remote_address()

func _clear_peer() -> void:
	connected_address = ""
	if peer != null:
		peer.close()
		peer = null
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer = null

func _load_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_connected_to_server() -> void:
	# Cache the resolved address here: asking ENet later can race with a
	# disconnect and log an engine error.
	connected_address = describe_peer(1)
	if connected_address.is_empty():
		connected_address = room_address
	print("[multiplayer] connected to host (%s)" % connected_address)
	_load_game()

func _on_connection_failed() -> void:
	print("[multiplayer] could not reach %s:%d" % [room_address, room_port])
	_clear_peer()
	is_host = false
	connection_failed.emit()

func _on_server_disconnected() -> void:
	print("[multiplayer] host closed the connection")
	_clear_peer()
	is_host = false
	server_disconnected.emit()

func _on_peer_connected(id: int) -> void:
	print("[multiplayer] peer %d connected from %s. Players: %d/%d" % [
		id, describe_peer(id), get_peer_count(), max_players
	])

func _on_peer_disconnected(id: int) -> void:
	print("[multiplayer] peer %d disconnected. Players: %d/%d" % [
		id, get_peer_count(), max_players
	])
