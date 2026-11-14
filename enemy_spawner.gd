extends Node2D

@export var Enemy : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var enemy = Enemy.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_transform = $EnemySpawnerMarker.global_transform


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
