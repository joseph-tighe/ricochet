# Bullet.gd — attached to the bullet scene's root
extends CharacterBody2D

@export var speed := 3000.0
@export var direction := Vector2.RIGHT
@export var dmgLimit = 1025
@export var lifetime := 100
var damage = 1

func _physics_process(delta: float) -> void:
	# Bullets are not synchronized; remove them after a while on every peer so
	# they cannot pile up in the scene.
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return

	rotateTowards()
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("player"):
			_apply_player_damage(collider)
			queue_free()
			return
		elif collider.is_in_group("enemy"):
			# In multiplayer the server owns enemy state.
			if not multiplayer.has_multiplayer_peer() or multiplayer.is_server():
				collider.health -= damage
			queue_free()
			return
		direction = direction.bounce(collision.get_normal()).normalized()
		if damage < dmgLimit:
			damage *= 2
			if damage > dmgLimit:
				queue_free()

func _apply_player_damage(player: Node) -> void:
	if not multiplayer.has_multiplayer_peer():
		player.health -= damage
		return

	# Only the server decides bullet hits. It sends the damage to the player's
	# authority so the health change is applied where health is authoritative.
	if not multiplayer.is_server():
		return

	var authority := player.get_multiplayer_authority()
	if authority == multiplayer.get_unique_id():
		player.take_damage(damage)
	else:
		player.take_damage.rpc_id(authority, damage)

func rotateTowards() -> void:
	rotate(atan2(direction.y, direction.x)-rotation);
