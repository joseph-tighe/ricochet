extends Node2D

@export var max_health := 10.0
@export var bar_width := 56.0
@export var bar_height := 7.0

var health_ratio := 1.0

func _process(_delta: float) -> void:
	var enemy = get_parent()
	if enemy != null:
		health_ratio = clampf(float(enemy.get("health")) / max_health, 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	var background := Rect2(-bar_width / 2.0, 0.0, bar_width, bar_height)
	draw_rect(background, Color(0.08, 0.08, 0.08, 0.9))
	draw_rect(Rect2(background.position, Vector2(bar_width * health_ratio, bar_height)), Color(0.9, 0.12, 0.12))
