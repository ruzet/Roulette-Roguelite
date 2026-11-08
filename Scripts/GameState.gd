extends Node

var RunSeed = 0
var RNG = RandomNumberGenerator.new()

func StartRun(Seed: String):
	if Seed.strip_edges() == "":
		RunSeed = randi()
	else:
		RunSeed = Seed.hash()

	RNG.seed = RunSeed
	get_tree().change_scene_to_file("res://Scenes/MainGame.tscn")