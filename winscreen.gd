extends Control

@onready var lvl1_button: TextureButton = $level


func _ready() -> void:
	lvl1_button.pressed.connect(_on_l1_pressed)


func _on_l1_pressed() -> void:
	lvl1_button.disabled = true
	get_tree().change_scene_to_file("res://lvl select.tscn")
