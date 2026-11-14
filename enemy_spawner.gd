extends Node2D
@export var Enemy : PackedScene

func _ready() -> void:
	spawn()

func _physics_process(delta: float) -> void:
	pass

func spawn() -> void:
	for marker in get_children():
		if marker is Marker2D:
			var enemy = Enemy.instantiate()
			get_tree().current_scene.add_child.call_deferred(enemy)
			enemy.set_deferred("global_transform", marker.global_transform)
