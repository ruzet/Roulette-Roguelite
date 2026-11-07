extends Control
@onready var SeedInput: LineEdit = $CenterContainer/VBoxContainer/SeedInput

func _ready() -> void:
	$CenterContainer/VBoxContainer/StartButton.pressed.connect(Start)
	$CenterContainer/VBoxContainer/BackButton.pressed.connect(Back)
	SeedInput.text_submitted.connect(func(_t): Start())

func Start():
	GameState.StartRun(SeedInput.text)

func Back():
	get_tree().change_scene_to_file("res://MainMenu.tscn")