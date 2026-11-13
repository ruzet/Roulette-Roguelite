class_name PocketDimension
extends CharmData

func OnAdded(Game: Node): Game.CharmLimit += 2
func OnRemoved(Game: Node): Game.CharmLimit -= 2
