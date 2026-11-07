extends Node2D

@export var ResultFormat := "Landed: %s Net: %+d"
@export var OutOfChipsText := "   (out of chips)"

@onready var Wheel: RouletteWheel = %RouletteWheel
@onready var Table: BettingTable = %BettingTable
@onready var SpinButton: Button = %SpinButton
@onready var ResultLabel: Label = %ResultLabel
@onready var WheelArea: Control = %WheelArea

const Stakes = [1, 5, 10, 25, 50, 100]

var Source := PocketSet.new()
var Book := BetBook.new()
var StakeIndex = 1

func _ready() -> void:
	Wheel.Source = Source
	Wheel.BallCount = 1

	Source.AddNumber(0, &"Green")
	for N in range(1, 100): Source.AddNumber(N, &"Red" if N % 2 == 1 else &"Black")
	Table.Bind(Source, Book)

	SpinButton.pressed.connect(_OnSpinPressed)
	Wheel.SpinFinished.connect(_OnSpinFinished)
	WheelArea.resized.connect(_PlaceWheel)
	%PlusButton.pressed.connect(_ChangeStake.bind(1))
	%MinusButton.pressed.connect(_ChangeStake.bind(-1))
	Book.Changed.connect(_UpdateButton)
	_PlaceWheel.call_deferred()
	_UpdateButton()

func _UpdateButton() -> void:
	SpinButton.disabled = Wheel.Spinning or Book.Bets.is_empty()

func _PlaceWheel():
	var AreaSize = WheelArea.size
	Wheel.position = AreaSize / 2
	var Fit = minf(AreaSize.x, AreaSize.y) / (Wheel.Radius * 2.2)
	Wheel.scale = Vector2(Fit, Fit)

func _ChangeStake(Step: int):
	StakeIndex = clampi(StakeIndex + Step, 0, Stakes.size() - 1)
	Table.ChipValue = Stakes[StakeIndex]
	%StakeLabel.text = str(Table.ChipValue)
	Book.Changed.emit()
	

func _OnSpinPressed() -> void:
	if Wheel.Spinning or Book.Bets.is_empty(): return
	Table.Locked = true
	ResultLabel.text = "Spinning..."
	Wheel.Spin()
	_UpdateButton()

func _OnSpinFinished(Results: Array[PocketData]) -> void:
	var R := Book.ResolveBets(Results)
	Table.Locked = false
	var Numbers := ", ".join(Results.map(func(P): return str(P.Number)))
	ResultLabel.text = ResultFormat % [Numbers, R.Net]
	if Book.Balance <= 0:
		ResultLabel.text += OutOfChipsText
	_UpdateButton()
