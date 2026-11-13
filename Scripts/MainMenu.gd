extends Control

func _ready() -> void:
	$CenterContainer/ButtonsContainer/PlayButton.pressed.connect(Play)
	$CenterContainer/ButtonsContainer/QuitButton.pressed.connect(get_tree().quit)

func Play(): GameState.StartRun("")
