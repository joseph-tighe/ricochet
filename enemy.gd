extends CharacterBody2D
@export var Bullet : PackedScene

@onready var cooldown_timer: Timer = $CooldownTimer
var can_shoot := true
@export var health = 10
@export var sight = 1000

func _ready() -> void:
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)

func _physics_process(_delta: float) -> void:
	if health <= 0:
		queue_free()
		return

	if not can_shoot:
		return

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var origin: Vector2 = $EnemyMarker.global_position
	var dir_vect: Vector2 = player.global_position - origin

	if dir_vect.length() > sight:
		return

	var query := PhysicsRayQueryParameters2D.create(
		origin,
		player.global_position
	)
	query.exclude = [get_rid()] # Don't let this enemy block its own ray.

	var hit := get_world_2d().direct_space_state.intersect_ray(query)

	if hit.is_empty() or hit.collider != player:
		return

	can_shoot = false
	cooldown_timer.start(0.3)
	shoot(dir_vect)


func _on_cooldown_timer_timeout() -> void:
	can_shoot = true
	

func shoot(dirVect):
	var bullet = Bullet.instantiate()
	get_tree().current_scene.add_child(bullet)
	dirVect = dirVect.normalized()
	dirVect += Vector2(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1))
	bullet.get_child(0).direction = dirVect
	bullet.global_transform = $EnemyMarker.global_transform
	bullet.get_child(0).rotateTowards()
	bullet.global_position = $EnemyMarker.global_position \
		+ 120.0 * dirVect	
