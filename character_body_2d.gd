extends CharacterBody2D
@export var Bullet : PackedScene

const SPEED = 300.0
@onready var cooldown_timer: Timer = $CooldownTimer
var can_shoot := true
@export var health = 100

func _ready() -> void:
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)

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
	if Input.is_action_pressed("shoot") and can_shoot:
		can_shoot = false
		cooldown_timer.start(0.2) # Cooldown in seconds
		shoot()
	velocity = direction.normalized() * SPEED
	move_and_slide()

func _on_cooldown_timer_timeout() -> void:
	can_shoot = true
	
func shoot():
	var bullet = Bullet.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.get_child(0).direction = (get_global_mouse_position()-$Marker2D.global_position).normalized()
	bullet.global_transform = $Marker2D.global_transform
	bullet.get_child(0).rotateTowards()
	bullet.global_position = $Marker2D.global_position \
		+ 120.0 * (get_global_mouse_position() - $Marker2D.global_position).normalized()	
