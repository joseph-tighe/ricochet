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
var max_players := 2

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# Host a room. Returns OK, or an error code if the port could not be opened.
func create_room(player_name: String, port: int = DEFAULT_PORT, players: int = 2) -> Error:
	username = player_name.strip_edges()
	is_host = true
	room_port = port
	room_address = "localhost"
	max_players = players

	_clear_peer()
	peer = ENetMultiplayerPeer.new()
	# max_players counts the host, but create_server expects a client count.
	var err := peer.create_server(port, maxi(1, players - 1))
	if err != OK:
		peer = null
		return err

	multiplayer.multiplayer_peer = peer
	_load_game()
	return OK

# Join a room. The level is loaded once the server accepts the connection.
func join_room(player_name: String, address: String, port: int = DEFAULT_PORT) -> Error:
	username = player_name.strip_edges()
	is_host = false
	room_port = port
	room_address = address

	_clear_peer()
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_client(address, port)
	if err != OK:
		peer = null
		return err

	multiplayer.multiplayer_peer = peer
	return OK

func leave_room() -> void:
	_clear_peer()
	get_tree().change_scene_to_file(MENU_SCENE)

# Best guess at the address other machines on the network should connect to.
func get_local_ip() -> String:
	for address in IP.get_local_addresses():
		if address.contains(":"):
			continue # IPv6
		if address.begins_with("127.") or address.begins_with("169.254."):
			continue
		return address
	return "127.0.0.1"

func _clear_peer() -> void:
	if peer != null:
		peer.close()
		peer = null
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer = null
	is_host = false

func _load_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_connected_to_server() -> void:
	_load_game()

func _on_connection_failed() -> void:
	_clear_peer()
	connection_failed.emit()

func _on_server_disconnected() -> void:
	_clear_peer()
	server_disconnected.emit()
