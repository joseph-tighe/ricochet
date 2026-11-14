extends CharacterBody2D
@export var Bullet : PackedScene

const SPEED = 300.0


func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO

	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1
	if Input.is_action_pressed("shoot"):
		shoot()
		
	velocity = direction.normalized() * SPEED
	move_and_slide()

func shoot():
	var bullet = Bullet.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.get_child(0).direction = Vector2.LEFT
	bullet.global_transform = $Marker2D.global_transform
	
