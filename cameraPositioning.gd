extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	var diffVector = get_global_mouse_position()-player.global_position
	var newPose = player.global_position+diffVector/5
	global_position = newPose
