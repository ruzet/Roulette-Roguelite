class_name LuckSystem
extends RefCounted

var _NumberMods: Array = []
var _ColorMods: Array = []

func AddNumberMod(Source: Variant, Number: int, Mult: float):
	_NumberMods.append({"Source": Source, "Key": Number, "Mult": Mult})

func AddColorMod(Source: Variant, ColorID: StringName, Mult: float):
	_NumberMods.append({"Source": Source, "Key": ColorID, "Mult": Mult})

func Clear():
	_NumberMods.clear()
	_ColorMods.clear()

func GetWeight(Pocket: PocketData):
	var FinalWeight = Pocket.BaseWeight

	for Mult in _NumberMods:
		if Mult.Key == Pocket.Number:
			FinalWeight *= Mult

	for Mult in _ColorMods:
		if Mult.Key == Pocket.ColorID:
			FinalWeight *= Mult

	return maxf(FinalWeight, 0.0)

func Pick(Pockets: Array[PocketData], RNG: RandomNumberGenerator):
	var Weights: Array[float] = []
	var Total = 0.0

	for Pocket in Pockets:
		var Weight = GetWeight(Pocket)
		Weights.append(Weight)
		Total += Weight
	
	if Total <= 0.0:
		return RNG.randi_range(0, Pockets.size() - 1)
	
	var Roll = RNG.randf() * Total
	
	for i in Weights.size():
		Roll -= Weights[i]
		if Roll <= 0.0:
			return i

	return Weights.size() - 1

