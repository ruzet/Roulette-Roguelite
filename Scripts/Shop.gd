class_name Shop
extends Control

signal PocketPicked(Template: PocketTemplate)
signal Closed

@export var PocketPool: Array[PocketTemplate] = []
@export var OfferCount = 3
@export var CardScene: PackedScene
@onready var Offers: Container = %Offers

var _RNG: RandomNumberGenerator

func Open(ShopRNG: RandomNumberGenerator):
	_RNG = ShopRNG
	for Child in Offers.get_children(): Child.queue_free()
	for Template in _Roll(OfferCount):
		var Card = CardScene.instantiate() as PocketCard
		Offers.add_child(Card)
		Card.Setup(Template)
		Card.Chosen.connect(_OnChosen)
	show()

func _Roll(Count: int):
	var Pool = PocketPool.duplicate()
	var Picked: Array[PocketTemplate] = []
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

func _OnChosen(Template: PocketTemplate):
	print("chosen: ", Template, "  connections: ", PocketPicked.get_connections().size())
	PocketPicked.emit(Template)
	hide()
	Closed.emit()