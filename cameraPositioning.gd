extends Camera2D

# How far the camera drifts toward the mouse (higher = less drift).
@export var look_ahead := 5.0

# The camera sits on the player it should follow. Cameras placed directly in a
# level instead fall back to the first player in the scene.
func _get_target() -> Node2D:
	var parent := get_parent()
	if parent is Node2D and parent.is_in_group("player"):
		return parent
	return get_tree().get_first_node_in_group("player") as Node2D

func _process(_delta: float) -> void:
	var target := _get_target()
	if target == null:
		return

	# In multiplayer only the peer that owns the player drives its camera.
	if target.has_method("is_local_player") and not target.is_local_player():
		enabled = false
		return

	# Re-assert every frame so a remote player's camera cannot take over.
	enabled = true
	make_current()

	var diff := get_global_mouse_position() - target.global_position
	global_position = target.global_position + diff / look_ahead
