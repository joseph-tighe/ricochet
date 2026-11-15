extends CharacterBody2D
@export var Bullet : PackedScene

const SPEED = 300.0
@onready var cooldown_timer: Timer = $CooldownTimer
var can_shoot := true
@export var health = 40
@export var username := "":
	set(value):
		username = value
		if is_node_ready():
			_update_name_label()
var isLeft := true;

func _ready() -> void:
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	# Own player: use the name typed on the create/join screen. Remote players
	# get their name through the MultiplayerSynchronizer.
	if is_multiplayer_authority() and username.is_empty():
		username = MultiplayerHandler.username
	_update_name_label()

func _update_name_label() -> void:
	var label := get_node_or_null("NameLabel")
	if label != null:
		label.text = username

func _physics_process(delta: float) -> void:
	# Only the peer that owns this player should process input/movement.
	# Remote peers receive state through the MultiplayerSynchronizer.
	if not is_multiplayer_authority():
		return

	var direction = Vector2.ZERO

	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1

	isLeft = (get_global_mouse_position()-$Marker2D.global_position).x < 0
	$AnimatedSprite2D.flip_h = isLeft
	if Input.is_action_pressed("shoot") and can_shoot:
		can_shoot = false
		cooldown_timer.start(0.2) # Cooldown in seconds
		shoot()
		if direction == Vector2.ZERO:
			$AnimatedSprite2D.animation = "shooting"
		else:
			$AnimatedSprite2D.animation = "shooting+running"
	elif can_shoot:
		if direction == Vector2.ZERO:
			$AnimatedSprite2D.animation = "idle"
		else:
			$AnimatedSprite2D.animation = "running"
	velocity = direction.normalized() * SPEED
	move_and_slide()

func _on_cooldown_timer_timeout() -> void:
	can_shoot = true

# Health is authoritative on the peer that owns this player, so bullet damage
# is forwarded here by the server (see test.gd). Any other sender is ignored.
@rpc("any_peer", "call_remote", "reliable")
func take_damage(amount: int) -> void:
	# get_remote_sender_id() is 0 for direct calls, so only RPC calls are filtered.
	var sender := multiplayer.get_remote_sender_id()
	if sender != 0:
		if sender != 1:
			return
		if not is_multiplayer_authority():
			return
	health -= amount

# True on the peer that controls this player (always true in single player).
func is_local_player() -> bool:
	if not multiplayer.has_multiplayer_peer():
		return true
	return is_multiplayer_authority()

func shoot():
	if not is_multiplayer_authority():
		return
	var aim = (get_global_mouse_position() - $Marker2D.global_position).normalized()
	var spawn_position = $Marker2D.global_position + 70.0 * aim
	if multiplayer.has_multiplayer_peer():
		spawn_bullet.rpc(spawn_position, aim)
	else:
		spawn_bullet(spawn_position, aim)

# Runs on every peer so everyone sees the same bullet.
@rpc("authority", "call_local", "reliable")
func spawn_bullet(bullet_position: Vector2, bullet_direction: Vector2) -> void:
	var bullet = Bullet.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.get_child(0).direction = bullet_direction
	bullet.global_position = bullet_position
	bullet.get_child(0).rotateTowards()
