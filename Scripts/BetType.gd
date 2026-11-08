class_name BetType
extends Resource

@export var ID: StringName
@export var DisplayName = ""
@export var Payout = 1
@export var Numbers: Array[int] = []
@export var Colors: Array[StringName] = []
@export var Parity = 0
@export var MinRange = 0
@export var MaxRange = -1

func Matches(Pocket: PocketData):
	if Numbers.has(Pocket.Number) or Colors.has(Pocket.ColorID): return true
	if Pocket.Number > 0: 
		if Parity == 1 && Pocket.Number % 2 == 1: return true
		if Parity == 2 && Pocket.Number % 2 == 0: return true
	
	return MaxRange >= MinRange && Pocket.Number >= MinRange && Pocket.Number <= MaxRange

static func _Make(PID: StringName, PName: String):
	var Bet = BetType.new()
	Bet.ID = PID
	Bet.DisplayName = PName
	return Bet

static func Straight(Number: int):
	var Bet = _Make(StringName("n%d" % Number), str(Number))
	Bet.Numbers.append(Number)
	return Bet

static func Color(ColorID: StringName):
	var Bet = _Make(StringName("c_" + ColorID), str(ColorID).capitalize())
	Bet.Colors.append(ColorID)
	return Bet

static func Even():
	var Bet = _Make(&"Even", "Even")
	Bet.Parity = 2
	return Bet

static func Odd():
	var Bet = _Make(&"Odd", "Odd")
	Bet.Parity = 1
	return Bet