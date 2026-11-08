class_name  PocketCard
extends Button
signal Chosen(Template: PocketTemplate)

var Template: PocketTemplate

@onready var TitleLabel: Label = %TitleLabel
@onready var DescriptionLabel: Label = %DescriptionLabel
@onready var Swatch: ColorRect = %Swatch

func Setup(NewTemplate: PocketTemplate):
	Template = NewTemplate
	TitleLabel.text = Template.Title
	DescriptionLabel.text = Template.Description
	Swatch.color = Template.DisplayColor

func _ready() -> void:
	pressed.connect(_OnPressed)

func _OnPressed():
	Chosen.emit(Template)