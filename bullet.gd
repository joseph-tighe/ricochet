extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	save_as_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func save_as_scene():
	var file_path = "res://bullet.tscn"
	var scene = PackedScene.new()
	scene.pack(get_node("."))
	ResourceSaver.save(scene, file_path)
