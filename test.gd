# Bullet.gd — attached to the bullet scene's root
extends CharacterBody2D

@export var speed := 1000.0
@export var direction := Vector2.RIGHT
var damage = 1

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("player"):
			collider.health -= damage
			queue_free()
		elif collider.is_in_group("enemy"):
			print("Hit enemy")
		direction = direction.bounce(collision.get_normal()).normalized()
		rotateTowards()
		damage *= 2
func rotateTowards() -> void:
	rotate(atan2(direction.y, direction.x));
