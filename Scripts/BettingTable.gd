class_name BettingTable
extends VBoxContainer
signal BetPlaced(Type: BetType)

@export var ChipValue = 5
@export var HouseEdge = 0.02
@export var TintByColor = true
@export var InfoFormat = "Total Staked: %d"
@export var BetButtonScene: PackedScene
@export var StakeFormat = "Stake: %d"

var Locked = false
var Source = PocketSet.new()
var Book = BetBook.new()
var Buttons = {}

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
	Buttons.clear()
	for Child in NumbersGrid.get_children():
		Child.queue_free()
	for Child in OutsideBets.get_children():
		Child.queue_free()
	var Seen = {}
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
	var Hits = 0
	var NewButton: Button
	for P in Source.Pockets: if Type.Matches(P): Hits += 1
	if Hits > 0: Type.Payout = maxf(floorf(float(Source.Pockets.size()) / Hits * (1.0 - HouseEdge)) - 1.0, 0.0)
	if BetButtonScene:
		NewButton = BetButtonScene.instantiate() as Button
	else:
		NewButton = Button.new()
		NewButton.custom_minimum_size = Vector2(70, 40)
	NewButton.text = Type.DisplayName
	NewButton.find_child("BetLabel", true).text = Type.DisplayName
	NewButton.set_meta("BaseText", Type.DisplayName)
	NewButton.disabled = Hits == 0
	NewButton.tooltip_text = "Pays %d:1" % int(Type.Payout)
	Buttons[Type.ID] = NewButton
	NewButton.pressed.connect(_OnBetPressed.bind(Type))
	Parent.add_child(NewButton)
	if TintByColor and Tint != Color.WHITE: _TintButton(NewButton, Tint)

func _OnClearPressed() -> void: if not Locked: Book.Clear()
func _RefreshInfo() -> void: 
	ChipsLabel.text = InfoFormat % Book.TotalStaked()
	_RefreshStakes()

func _OnBetPressed(Type: BetType) -> void:
	if Locked: return
	if Book.PlaceBet(Type, ChipValue): BetPlaced.emit(Type)

func _TintButton(B: Button, Tint: Color) -> void:
	for StateName in ["normal", "hover", "pressed", "disabled"]:
		var Base = B.get_theme_stylebox(StateName)
		var Box: StyleBoxFlat
		if Base is StyleBoxFlat:
			Box = Base.duplicate()
		else:
			Box = StyleBoxFlat.new()
		match StateName:
			"hover": Box.bg_color = Tint.lightened(0.2)
			"pressed": Box.bg_color = Tint.darkened(0.2)
			"disabled": Box.bg_color = Tint.darkened(0.5)
			_: Box.bg_color = Tint
		B.add_theme_stylebox_override(StateName, Box)

func _RefreshStakes():
	var Stakes = {}
	for Bet in Book.Bets: Stakes[Bet.Type.ID] = Bet.Stake
	for ID in Buttons:
		var B: Button = Buttons[ID]
		if is_instance_valid(B):
			_ShowStake(B, Stakes.get(ID, 0))

func _ShowStake(B: Button, Stake: int):
	var BetLabel = B.get_node_or_null("LabelContainer/BetLabel") as Label
	var StakeLabel = B.get_node_or_null("LabelContainer/StakeLabel") as Label
	
	if StakeLabel && BetLabel:
		if Stake > 0:
			B.add_theme_color_override("font_color", Color.from_rgba8(255, 255, 255, 0))
			B.add_theme_color_override("font_hover_color", Color.from_rgba8(255, 255, 255, 0))
			B.add_theme_color_override("font_focus_color", Color.from_rgba8(255, 255, 255, 0))
			B.add_theme_color_override("font_pressed_color", Color.from_rgba8(255, 255, 255, 0))
		else:
			B.remove_theme_color_override("font_color")
			B.remove_theme_color_override("font_hover_color")
			B.remove_theme_color_override("font_focus_color")
			B.remove_theme_color_override("font_pressed_color")

		BetLabel.visible = Stake > 0
		StakeLabel.visible = Stake > 0
		StakeLabel.text = StakeFormat % Stake
