extends Node2D
@export var bar : PackedScene

func _ready() -> void:
	spawn()

func _physics_process(delta: float) -> void:
	pass

func spawn() -> void:
	var ui = bar.instantiate()
	get_tree().current_scene.add_child.call_deferred(ui)
