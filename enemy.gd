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
		cooldown_timer.start(0.3) # Cooldown in seconds
		shoot()
	if health < 0:
		queue_free()

func _on_cooldown_timer_timeout() -> void:
	can_shoot = true
	

func shoot():
	var bullet = Bullet.instantiate()
	var player = get_tree().get_first_node_in_group("player")
	get_tree().current_scene.add_child(bullet)
	var dirVect: Vector2 = (player.global_position-$EnemyMarker.global_position)
	if dirVect.length() > 1000:
		return;
	dirVect = dirVect.normalized()
	dirVect += Vector2(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1))
	bullet.get_child(0).direction = dirVect
	bullet.global_transform = $EnemyMarker.global_transform
	bullet.get_child(0).rotateTowards()
	bullet.global_position = $EnemyMarker.global_position \
		+ 120.0 * dirVect	
