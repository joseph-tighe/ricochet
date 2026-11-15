extends ColorRect

const MAX_HEALTH := 40.0
const HORIZONTAL_MARGIN := 24.0

# Set by UI.gd to the player this bar belongs to.
var player: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Every player spawns a HUD; only the one for the local player is shown.
	if not _is_local_owner():
		visible = false
		var background := get_parent().get_node_or_null("Background")
		if background != null:
			background.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not _is_local_owner():
		return
	if player == null:
		player = _find_local_player()
	if player == null:
		return
	var health_ratio := clampf(player.health / MAX_HEALTH, 0.0, 1.0)
	var available_width := get_viewport_rect().size.x - HORIZONTAL_MARGIN * 2.0
	size.x = available_width * health_ratio

func _is_local_owner() -> bool:
	if player == null:
		return true
	if player.has_method("is_local_player"):
		return player.is_local_player()
	return true

func _find_local_player() -> Node:
	for candidate in get_tree().get_nodes_in_group("player"):
		if candidate.has_method("is_local_player") and candidate.is_local_player():
			return candidate
	return null
