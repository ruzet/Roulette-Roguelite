class_name BetBook
extends RefCounted
signal Changed

var Balance = 100
var PayoutMultiplier = 1
var Bets = []
var NumberPayoutMods: Array = []
var ColorPayoutMods: Array = []

func AddNumberPayout(Origin: Variant, Number: int, Mult: float):
	NumberPayoutMods.append({"Origin": Origin, "Key": Number, "Mult": Mult})

func AddColorPayout(Origin: Variant, ColorID: StringName, Mult: float):
	ColorPayoutMods.append({"Origin": Origin, "Key": ColorID, "Mult": Mult})

func RemovePayoutSource(Origin: Variant):
	NumberPayoutMods = NumberPayoutMods.filter(func(M): return M.Origin != Origin)
	ColorPayoutMods = ColorPayoutMods.filter(func(M): return M.Origin != Origin)

func PayoutMultiplierFor(Pocket: PocketData):
	var Total: float = PayoutMultiplier
	for M in NumberPayoutMods: if M.Key == Pocket.Number: Total *= M.Mult
	for M in ColorPayoutMods: if M.Key == Pocket.ColorID: Total *= M.Mult
	return Total * Pocket.Extra.get("PayoutMultiplier", 1.0)

func PlaceBet(Type: BetType, Stake: int):
	var Existing = false
	if Stake <= 0 or Stake > Balance: return false
	Balance -= Stake

	for Bet in Bets:
		if Bet.Type.ID == Type.ID:
			Bet.Stake += Stake
			Existing = true
			break
	
	if not Existing: Bets.append({"Type": Type, "Stake": Stake})
	Changed.emit()
	return true

func TotalStaked():
	var Total = 0
	for Bet in Bets: Total += Bet.Stake
	return Total

func Clear():
	Balance += TotalStaked()
	Bets.clear()
	Changed.emit()

func ResolveBets(Results: Array[PocketData]) -> Dictionary:
	var Staked = TotalStaked()
	var Returned = 0.0

	for Bet in Bets:
		var Won = false
		var Multiplier = 0.0
		for Pocket in Results:
			if Bet.Type.Matches(Pocket):
				Won = true
				Multiplier += PayoutMultiplierFor(Pocket)
		if Won: Returned += Bet.Stake + Bet.Stake * Bet.Type.Payout * Multiplier
	var Paid = roundi(Returned)
	Bets.clear()
	Balance += Paid
	Changed.emit()
	return {"Staked": Staked, "Paid": Paid, "Net": Paid - Staked}
