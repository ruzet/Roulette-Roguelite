class_name BettingTable
extends VBoxContainer
signal BetPlaced(Type: BetType)

@export var ChipValue := 5
@export var HouseEdge := 0.02
@export var TintByColor := true
@export var InfoFormat := "Total Staked: %d (Stake = %d)"
@export var BetButtonScene: PackedScene

var Locked := false
var Source := PocketSet.new()
var Book := BetBook.new()

@onready var ChipsLabel: Label = %ChipsLabel
@onready var NumbersGrid: Container = %NumbersGrid
@onready var OutsideBets: Container = %OutsideBets
@onready var ClearButton: Button = %ClearButton

func _ready() -> void:
	ClearButton.pressed.connect(_OnClearPressed)

func Bind(NewSource: PocketSet, NewBook: BetBook) -> void:
	Source = NewSource
	Book = NewBook
	Source.Changed.connect(_Rebuild)
	Book.Changed.connect(_RefreshInfo)
	_Rebuild()
	_RefreshInfo()

func _Rebuild() -> void:
	for Child in NumbersGrid.get_children():
		Child.queue_free()
	for Child in OutsideBets.get_children():
		Child.queue_free()
	var Seen := {}
	for P in Source.Pockets:
		if Seen.has(P.Number):
			continue
		Seen[P.Number] = true
		_AddButton(NumbersGrid, BetType.Straight(P.Number), Source.ColorTable.get(P.ColorID, Color.WHITE))
	for ColorID in Source.Colors():
		_AddButton(OutsideBets, BetType.Color(ColorID), Source.ColorTable.get(ColorID, Color.WHITE))
	_AddButton(OutsideBets, BetType.Odd())
	_AddButton(OutsideBets, BetType.Even())

func _AddButton(Parent: Container, Type: BetType, Tint = Color.WHITE) -> void:
	var Hits := 0
	var NewButton: Button
	for P in Source.Pockets: if Type.Matches(P): Hits += 1
	if Hits > 0: Type.Payout = maxf(floorf(float(Source.Pockets.size()) / Hits * (1.0 - HouseEdge)) - 1.0, 0.0)
	if BetButtonScene:
		NewButton = BetButtonScene.instantiate() as Button
	else:
		NewButton = Button.new()
		NewButton.custom_minimum_size = Vector2(70, 40)
	NewButton.text = Type.DisplayName
	NewButton.add_theme_font_size_override("thingie", 50)
	if TintByColor: NewButton.self_modulate = Tint
	NewButton.disabled = Hits == 0
	NewButton.tooltip_text = "Pays %d:1" % int(Type.Payout)
	NewButton.pressed.connect(_OnBetPressed.bind(Type))
	Parent.add_child(NewButton)

func _OnBetPressed(Type: BetType) -> void:
	if Locked:
		return
	if Book.PlaceBet(Type, ChipValue):
		BetPlaced.emit(Type)

func _OnClearPressed() -> void:
	if not Locked:
		Book.Clear()

func _RefreshInfo() -> void:
	ChipsLabel.text = InfoFormat % [Book.TotalStaked(), ChipValue]
