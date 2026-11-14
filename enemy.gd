extends CharacterBody2D
@export var Bullet : PackedScene

const SPEED = 300.0
var can_shoot := true
@export var health = 50

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if health < 0:
		queue_free()
	
func shoot():
	var bullet = Bullet.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.get_child(0).direction = (get_global_mouse_position()-$Marker2D.global_position).normalized()
	bullet.global_transform = $Marker2D.global_transform
	bullet.get_child(0).rotateTowards()
	bullet.global_position = $Marker2D.global_position \
		+ 120.0 * (get_global_mouse_position() - $Marker2D.global_position).normalized()	
