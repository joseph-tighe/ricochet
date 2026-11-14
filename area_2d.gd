# Bullet.gd — attached to the bullet scene's root
extends Area2D

@export var speed := 300.0
@export var direction := Vector2.RIGHT

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
