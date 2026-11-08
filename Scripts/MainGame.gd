extends Node2D

@export var ResultFormat := "Landed: %s Net: %+d"
@onready var Wheel: RouletteWheel = %RouletteWheel
@onready var Table: BettingTable = %BettingTable
@onready var SpinButton: Button = %SpinButton
@onready var ResultLabel: Label = %ResultLabel
@onready var WheelArea: Control = %WheelArea
@onready var ShopScreen: Shop = %Shop
signal SpinResolved(Result: Dictionary)
const Stakes = [1, 5, 10, 25, 50, 100]

var Source := PocketSet.new()
var Book := BetBook.new()
var ShopRNG = RandomNumberGenerator.new()
var StakeIndex = 1
var OwnedCharms: Array[CharmData] = []

var Round = -3
var SpinsLeft = 1
var Quota = 0

func _ready() -> void:
	Wheel.Source = Source
	Wheel.BallCount = 1
	ShopRNG.seed = GameState.RNG.seed + 1
	ShopScreen.PocketPicked.connect(Source.AddTemplate)
	ShopScreen.CharmBought.connect(AddCharm)

	Source.AddNumber(0, &"Green")
	for N in range(1, 37): Source.AddNumber(N, &"Red" if N % 2 == 1 else &"Black")
	Table.Bind(Source, Book)

	SpinButton.pressed.connect(_OnSpinPressed)
	Wheel.SpinFinished.connect(_OnSpinFinished)
	Wheel.BallLanded.connect(_OnBallLanded)
	WheelArea.resized.connect(_PlaceWheel)
	%PlusButton.pressed.connect(_ChangeStake.bind(1))
	%MinusButton.pressed.connect(_ChangeStake.bind(-1))
	Book.Changed.connect(_UpdateButton)
	_PlaceWheel.call_deferred()
	_UpdateButton()

func AddCharm(Charm: CharmData):
	var Owned = Charm.duplicate() as CharmData
	OwnedCharms.append(Owned)
	Owned.OnAdded(self)

func RemoveCharm(Charm: CharmData):
	if OwnedCharms.has(Charm):
		OwnedCharms.erase(Charm)
		Charm.OnRemoved(self)

func _UpdateButton() -> void:
	%CurrentChips.text = "Chips: " + str(Book.Balance)
	SpinButton.disabled = Wheel.Spinning or Book.Bets.is_empty()

func _WinRound():
	Round += 1
	if Round == 0: 
		Round = 1 
		Quota = 100
	elif Round > 1:
		Quota *= 2
	SpinsLeft = 3
	%CurrentRound.text = "Round: " + str(Round)
	%CurrentSpinsLeft.text = "Spins Left: " + str(SpinsLeft)
	ShopScreen.Open(ShopRNG, Book)

func _LoseRound():
	get_tree().quit()

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
	if Wheel.Spinning or Book.Bets.is_empty() or SpinsLeft <= 0: return
	Table.Locked = true
	ResultLabel.text = "Spinning..."
	Wheel.Spin()
	SpinsLeft -= 1
	%CurrentSpinsLeft.text = "Spins Left: " + str(SpinsLeft)
	_UpdateButton()

func _OnSpinFinished(Results: Array[PocketData]) -> void:
	var R := Book.ResolveBets(Results)
	SpinResolved.emit(R)
	Table.Locked = false
	var Numbers := ", ".join(Results.map(func(P): return str(P.Number)))
	ResultLabel.text = ResultFormat % [Numbers, R.Net]
	if Book.Balance <= 0:
		_LoseRound()
	if SpinsLeft <= 0:
		if Book.Balance <= Quota:
			_LoseRound()
		else:
			_WinRound()
	_UpdateButton()

func _OnBallLanded(_BallIndex: int, _Pocket: PocketData, _Context: Dictionary):
	if _Pocket.ColorID == &"LightGreen":
		Source.AddNumber(Source.Pockets.size(), &"LightGreen", 1)
	if _Pocket.ColorID == &"Purple":
		SpinsLeft += 1
		%CurrentSpinsLeft.text = "Spins Left: " + str(SpinsLeft)
	
