class_name PocketTemplate
extends Resource

@export var Title = "Blue"
@export_multiline var Description = ""
@export var ColorID: StringName = &"Blue"
@export var DisplayColor = Color.from_rgba8(0, 0, 180)
@export var BaseWeight = 1.0
@export var Effects: Array[PocketEffect] = []
@export var Extra: Dictionary = {}
@export var Icon: Texture2D
@export var ShopWeight = 1.0

func Build(Number: int):
	var Pocket = PocketData.new()
	Pocket.Number = Number
	Pocket.ColorID = ColorID
	Pocket.BaseWeight = BaseWeight
	Pocket.Effects = Effects.duplicate()
	Pocket.Extra = Extra.duplicate()
	return Pocket