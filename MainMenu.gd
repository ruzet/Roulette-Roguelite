extends Control

func _ready() -> void:
	$CenterContainer/ButtonsContainer/PlayButton.pressed.connect(Play)
	$CenterContainer/ButtonsContainer/SeedButton.pressed.connect(Seed)
	$CenterContainer/ButtonsContainer/QuitButton.pressed.connect(get_tree().quit)

func Play():
	GameState.StartRun("")

func Seed():
	get_tree().change_scene_to_file("res://SeedMenu.tscn")
