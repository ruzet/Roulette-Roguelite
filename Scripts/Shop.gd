extends Control

func _ready() -> void:
	for i in 3:
		var NewPocket = %Templates/TemplatePocket.duplicate()
		%Pockets.add_child(NewPocket)
		pass