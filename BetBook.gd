class_name BetBook
extends RefCounted
signal Changed

var Balance = 100
var PayoutMultiplier = 1
var Bets = []

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

func ResolveBets(Results: Array[PocketData]) -> Dictionary:
	var Staked = TotalStaked()
	var Returned = 0.0
	var Paid = 0

	for Bet in Bets:
		var Hits = 0
		for Pocket in Results: if Bet.Type.Matches(Pocket): Hits += 1
		if Hits > 0: Returned += Bet.Stake + Bet.Stake * Bet.Type.Payout * PayoutMultiplier * Hits
	
	Paid = roundi(Returned)
	Bets.clear()
	Balance += Paid
	Changed.emit()
	return {"Staked": Staked, "Paid": Paid, "Net": Paid - Staked}