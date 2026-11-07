class_name BettingTable
extends VBoxContainer
signal BetPlaced(Type: BetType)

## Payouts are worked out from the pool: floor(Pockets / matching * (1 - edge)) - 1
@export var ChipValue = 5
@export var HouseEdge = 0.02

var Locked = false
var Source = PocketSet.new()
var Book = BetBook.new()
var _Info: Label
var _Grid: GridContainer
var _Outside: HBoxContainer

func Bind(PSource: PocketSet, PBook: BetBook):
	Source = PSource
	Book = PBook
	Source.Changed.connect(_Rebuild)
	Book.Changed.connect(_RefreshInfo)
	_Rebuild()
	_RefreshInfo()

func _ready() -> void:
	_Info = Label.new()
	_Grid = GridContainer.new()
	_Grid.columns = 6
	_Outside = HBoxContainer.new()
	var Clear = Button.new()
	Clear.text = "Clear Bets"
	Clear.pressed.connect(func(): if not Locked: Book.clear())
	for N in [_Info, _Grid, _Outside, Clear]:
		add_child(N)

func _Rebuild() -> void:
	var Seen := {}
	for C in _Grid.get_children() + _Outside.get_children():
		C.queue_free()
	for Pocket in Source.Pockets:
		if Seen.has(Pocket):
			continue
		Seen[Pocket.Number] = true
		_AddButton(_Grid, BetType.Straight(Pocket.Number), Source.ColorTable.get(Pocket.ColorID, Color.WHITE))
	for C in Source.Colors():
		_AddButton(_Outside, BetType.Color(C), Source.ColorTable.get(C, Color.WHITE))
	_AddButton(_Outside, BetType.Odd())
	_AddButton(_Outside, BetType.Even())

func _AddButton(Parent: Control, Type: BetType, Tint := Color.WHITE) -> void:
	var Hits := 0
	var NewButton := Button.new()

	for Pocket in Source.Pockets: if Type.Matches(Pocket): Hits += 1
	if Hits > 0: Type.Payout = maxf(floorf(float(Source.Pockets.size()) / Hits * (1.0 - HouseEdge)) - 1.0, 0.0)
	NewButton.text = Type.DisplayName
	NewButton.custom_minimum_size = Vector2(44, 32)
	NewButton.self_modulate = Tint
	NewButton.disabled = Hits == 0
	NewButton.tooltip_text = "pays %d:1" % int(Type.Payout)
	NewButton.pressed.connect(func():
		if not Locked and Book.PlaceBet(Type, ChipValue): BetPlaced.emit(Type))
	Parent.add_child(NewButton)

func _RefreshInfo() -> void: if _Info: _Info.text = "Chips: %d   Staked: %d   (chip = %d)" % [Book.Balance, Book.TotalStaked(), ChipValue]
