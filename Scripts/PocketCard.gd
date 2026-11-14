class_name  PocketCard
extends Button
signal Chosen(Template: PocketTemplate)

var Template: PocketTemplate

@onready var TitleLabel: Label = %TitleLabel
@onready var DescriptionLabel: Label = %DescriptionLabel
@onready var Swatch: Panel = %Swatch

func Setup(NewTemplate: PocketTemplate):
	var NewStyleBox: StyleBox = Swatch.get_theme_stylebox("panel").duplicate()
	Template = NewTemplate
	TitleLabel.text = Template.Title
	DescriptionLabel.text = Template.Description
	NewStyleBox.bg_color = Template.DisplayColor
	Swatch.add_theme_stylebox_override("panel", NewStyleBox)

func _ready() -> void: pressed.connect(_OnPressed)
func _OnPressed(): Chosen.emit(Template)
