extends ColorRect

const MAX_HEALTH := 20.0
const HORIZONTAL_MARGIN := 24.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		var health_ratio := clampf(player.health / MAX_HEALTH, 0.0, 1.0)
		var available_width := get_viewport_rect().size.x - HORIZONTAL_MARGIN * 2.0
		size.x = available_width * health_ratio
