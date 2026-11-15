# Bullet.gd — attached to the bullet scene's root
extends CharacterBody2D

@export var speed := 3000.0
@export var direction := Vector2.RIGHT
@export var dmgLimit = 1025
var damage = 1

func _physics_process(delta: float) -> void:
	rotateTowards()
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("player"):
			collider.health -= damage
			queue_free()
		elif collider.is_in_group("enemy"):
			collider.health -= damage
			queue_free()
		direction = direction.bounce(collision.get_normal()).normalized()
		if damage < dmgLimit:
			damage *= 2
			if damage > dmgLimit:
				queue_free()
func rotateTowards() -> void:
	rotate(atan2(direction.y, direction.x)-rotation);
