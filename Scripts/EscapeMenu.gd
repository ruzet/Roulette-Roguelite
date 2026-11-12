extends Control

@onready var ResumeButton: Button = $"Background/ButtonsContainer/Resume"
@onready var MainMenuButton: Button = $"Background/ButtonsContainer/MainMenu"
@onready var QuitButton: Button = $"Background/ButtonsContainer/Quit"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Escape Menu"):
		self.visible = !self.visible
		
func Resume(): self.visible = false
func MainMenu(): get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
func Quit(): get_tree().quit()
		
func _ready() -> void:
	ResumeButton.pressed.connect(Resume)
	MainMenuButton.pressed.connect(MainMenu)
	QuitButton.pressed.connect(Quit)
