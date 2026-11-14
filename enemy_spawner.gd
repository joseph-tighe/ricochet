extends Node2D
@export var Enemy : PackedScene

func _ready() -> void:
	spawn()

func _physics_process(delta: float) -> void:
	pass

func spawn():
	var enemy = Enemy.instantiate()
	get_tree().current_scene.add_child.call_deferred(enemy)
	enemy.global_transform = $EnemyMarker1.global_transform
