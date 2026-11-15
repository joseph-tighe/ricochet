extends Node2D
@export var bar : PackedScene

func _ready() -> void:
	spawn()

func _physics_process(delta: float) -> void:
	pass

func spawn() -> void:
	var ui = bar.instantiate()
	# The HUD follows the player that owns this node.
	var body := get_parent().get_node_or_null("CharacterBody2D")
	if body != null and ui.has_node("HealthFill"):
		ui.get_node("HealthFill").player = body
	get_tree().current_scene.add_child.call_deferred(ui)
