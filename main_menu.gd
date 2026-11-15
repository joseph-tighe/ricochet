extends Control

@onready var play_button: TextureButton = $level
@onready var quit_button: TextureButton = $Quit

func _ready() -> void:
	play_button.pressed.connect(_on_level_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_level_pressed() -> void:
	play_button.disabled = true
	get_tree().change_scene_to_file("res://lvl select.tscn")



func _on_quit_pressed() -> void:
	quit_button.disabled = true
	get_tree().quit()
