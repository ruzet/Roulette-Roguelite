extends Control

@onready var ResumeButton: Button = $"Background/MarginContainer/ButtonsContainer/Resume"
@onready var MainMenuButton: Button = $"Background/MarginContainer/ButtonsContainer/MainMenu"
@onready var QuitButton: Button = $"Background/MarginContainer/ButtonsContainer/Quit"
		
func Resume(): self.visible = false
func MainMenu(): get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
func Quit(): get_tree().quit()
func _input(event: InputEvent) -> void: if event.is_action_pressed("Escape Menu"): self.visible = !self.visible
func _ready() -> void:
	ResumeButton.pressed.connect(Resume)
	MainMenuButton.pressed.connect(MainMenu)
	QuitButton.pressed.connect(Quit)
