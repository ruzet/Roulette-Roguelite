class_name CharmCard
extends Button
signal Chosen(Charm: CharmData)

@export var CostFormat = "Cost: %d"
@export var SoldText = "SOLD"

var Charm: CharmData
var Sold = false

@onready var TitleLabel: Label = %TitleLabel
@onready var DescriptionLabel: Label = %DescriptionLabel
@onready var CostLabel: Label = %CostLabel

func _ready() -> void: pressed.connect(_OnPressed)

func Setup(NewCharm: CharmData):
	Charm = NewCharm
	TitleLabel.text = Charm.Title
	DescriptionLabel.text = Charm.Description
	CostLabel.text = CostFormat % Charm.Cost

func Refresh(Chips: int): disabled = Sold or Chips < Charm.Cost
func MarkSold():
	Sold = true
	disabled = true
	CostLabel.text = SoldText

func _OnPressed(): Chosen.emit(Charm, self)
