extends Node2D

@onready var Wheel: RouletteWheel = $RouletteWheel
@onready var Table: BettingTable = $UI/BettingTable
@onready var SpinButton: Button = $UI/SpinButton
@onready var ResultLabel: Label = $UI/ResultLabel

var Source := PocketSet.new()
var Book := BetBook.new()

func _ready() -> void:
	var size := get_viewport_rect().size
	var Wheel_x := size.x * 0.72

	Wheel.Source = Source
	Wheel.position = Vector2(Wheel_x, size.y * 0.5)
	Wheel.BallCount = 1
	if has_node("/root/GameState"):
		Wheel.RNG = get_node("/root/GameState").RNG

	Source.AddNumber(0, &"Green")
	for N in range(1, 37):
		Source.AddNumber(N, &"Red" if N % 2 == 1 else &"Black")

	Table.position = Vector2(24, 24)
	Table.Bind(Source, Book)
	ResultLabel.position = Vector2(Wheel_x - 150, 20)
	ResultLabel.text = "Place a bet, then spin"
	SpinButton.text = "Spin"
	SpinButton.custom_minimum_size = Vector2(120, 44)
	SpinButton.position = Vector2(Wheel_x - 60, size.y - 80)

	SpinButton.pressed.connect(_OnSpinPressed)
	Wheel.SpinFinished.connect(_OnSpinFinished)
	Book.Changed.connect(_UpdateButton)
	_UpdateButton()
	Wheel.queue_redraw()

func _UpdateButton() -> void:
	SpinButton.disabled = Wheel.Spinning or Book.Bets.is_empty()

func _OnSpinPressed() -> void:
	if Wheel.Spinning or Book.Bets.is_empty():
		return
	Table.Locked = true
	ResultLabel.text = "Spinning..."
	Wheel.Spin()
	_UpdateButton()

func _OnSpinFinished(Results: Array[PocketData]) -> void:
	var ResolvedBet := Book.ResolveBets(Results)
	Table.Locked = false
	var Numbers := ", ".join(Results.map(func(Pocket): return str(Pocket.Number)))
	ResultLabel.text = "Landed: %s   Net: %+d" % [Numbers, ResolvedBet.Net]
	if Book.Balance <= 0:
		ResultLabel.text += "   (out of chips)"
	_UpdateButton()
