extends Control

@onready var lvl1_button: TextureButton = $lvl1
@onready var lvl2_button: TextureButton = $lvl2
@onready var lvl3_button: TextureButton = $lvl3

func _ready() -> void:
	lvl1_button.pressed.connect(_on_l1_pressed)
	lvl2_button.pressed.connect(_on_l2_pressed)
	lvl3_button.pressed.connect(_on_l3_pressed)

func _on_l1_pressed() -> void:
	lvl1_button.disabled = true
	get_tree().change_scene_to_file("res://lvl_1.tscn")

func _on_l2_pressed() -> void:
	lvl2_button.disabled = true
	get_tree().change_scene_to_file("res://lvl_2.tscn")
	
func _on_l3_pressed() -> void:
	lvl3_button.disabled = true
	get_tree().change_scene_to_file("res://lvl_2.tscn")
