class_name DisplayCharmCard
extends Panel

var Charm: CharmData
var Sold = false

@onready var TitleLabel: Label = $Margin/VBoxContainer/TitleLabel
@onready var DescriptionLabel: Label = $Margin/VBoxContainer/DescriptionLabel

func Setup(NewCharm: CharmData):
	Charm = NewCharm
	TitleLabel.text = Charm.Title
	DescriptionLabel.text = Charm.Description
