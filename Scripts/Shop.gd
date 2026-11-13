class_name Shop
extends Control

signal PocketPicked(Template: PocketTemplate)
signal CharmBought(Charm: CharmData)
signal Closed

@export var PocketPool: Array[PocketTemplate] = []
@export var OfferCount = 3
@export var CardScene: PackedScene
@export var CharmCardScene: PackedScene
@export var DisplayCharmCardScene: PackedScene
@export var CharmPool: Array[CharmData] = []
@export var CharmOfferCount = 1
@export var CharmTitle = "Buy Charms"
@export var PocketTitle = "Choose a Pocket"
@export var CashFormat = "Cash: %d$"

@onready var Offers: Container = %Offers
@onready var TitleLabel: Label = %Title
@onready var DoneButton: Button = %DoneButton

var OwnedCharms = []
var _RNG: RandomNumberGenerator
var _Book: BetBook

func _ready() -> void: DoneButton.pressed.connect(_Close)
func Open(ShopRNG: RandomNumberGenerator, ShopBook: BetBook, OwnedCharms: Array[CharmData]):
	var CharmAvailible = false
	_RNG = ShopRNG
	_Book = ShopBook
	TitleLabel.text = PocketTitle
	DoneButton.hide()
	_Clear()
	for Charm in CharmPool: if !OwnedCharms.has(Charm): CharmAvailible = true
	if CharmAvailible:
		for Template in _Roll(PocketPool, OfferCount):
			var Card = CardScene.instantiate() as PocketCard
			Offers.add_child(Card)
			Card.Setup(Template)
			Card.Chosen.connect(_OnPocketChosen)
		show()

func _Close():
	hide()
	Closed.emit()

func _Clear():
	for Child in Offers.get_children():
		Offers.remove_child(Child)
		Child.queue_free()

func _ShowCharms():
	TitleLabel.text = CharmTitle + " - Cash: " + str(_Book.Cash) +"$"
	_Clear()
	for Charm in _Roll(CharmPool, CharmOfferCount):
		var Card = CharmCardScene.instantiate() as CharmCard
		Offers.add_child(Card)
		Card.Setup(Charm)
		Card.Chosen.connect(_OnCharmChosen)
	_RefreshCharmCards()
	DoneButton.show()

func _RefreshCharmCards():
	for Child in Offers.get_children():
		if Child is CharmCard:
			Child.Refresh(_Book.Cash)

func _Roll(Items: Array, Count: int):
	var Pool = Items.duplicate()
	var Picked: Array = []
	for Charm in Pool: 
		if OwnedCharms.has(Charm): 
			Pool.remove_at(Pool.find(Charm))
	while Picked.size() < Count && !Pool.is_empty():
		var Total = 0.0
		for T in Pool: Total += T.ShopWeight
		var Roll = _RNG.randf() * Total
		var Index = 0
		for i in Pool.size():
			Roll -= Pool[i].ShopWeight
			if Roll <= 0:
				Index = i
				break
		Picked.append(Pool[Index])
		Pool.remove_at(Index)
	return Picked

func _OnPocketChosen(Template: PocketTemplate):
	PocketPicked.emit(Template)
	if CharmPool.is_empty() or CharmCardScene == null:
		_Close()
		return
	_ShowCharms()

func _OnCharmChosen(Charm: CharmData, Card: CharmCard):
	if Card.Sold || _Book.Cash < Charm.Cost: return
	_Book.Cash -= Charm.Cost
	TitleLabel.text = CharmTitle + " - Cash: " + str(_Book.Cash) +"$"
	_Book.Changed.emit()
	Card.MarkSold()
	CharmBought.emit(Charm)
	OwnedCharms.append(Charm)
	var DisplayCard = DisplayCharmCardScene.instantiate() as DisplayCharmCard
	%CharmScrollContainer/VBoxContainer.add_child(DisplayCard)
	DisplayCard.Setup(Charm)
	_RefreshCharmCards()
