extends CharacterBody2D
@export var Bullet : PackedScene

@onready var cooldown_timer: Timer = $CooldownTimer
var can_shoot := true
@export var health = 10

func _ready() -> void:
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)

func _physics_process(delta: float) -> void:
	if can_shoot:
		can_shoot = false
		cooldown_timer.start(1.5) # Cooldown in seconds
		shoot()
	if health < 0:
		queue_free()

func _on_cooldown_timer_timeout() -> void:
	can_shoot = true
	

func shoot():
	for i in range(8):
		var bullet = Bullet.instantiate()
		get_tree().current_scene.add_child(bullet)
		var dirVect = Vector2(1, 0).rotated(i/8*PI*2)
		dirVect += Vector2(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1))
		bullet.get_child(0).direction = dirVect
		bullet.global_transform = $EnemyMarker.global_transform
		bullet.get_child(0).rotateTowards()
		bullet.global_position = $EnemyMarker.global_position \
			+ 120.0 * dirVect	
