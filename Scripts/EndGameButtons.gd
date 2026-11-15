extends Control

func MainMenu(): get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
func Quit(): get_tree().quit()
func _ready() -> void:
	find_child("MainMenu").pressed.connect(MainMenu)
	find_child("Quit").pressed.connect(Quit)