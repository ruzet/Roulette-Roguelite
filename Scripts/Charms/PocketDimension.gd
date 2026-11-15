class_name PocketDimension
extends CharmData

func OnAdded(Game: Node): Game.ShopScreen.CharmLimit += 2
func OnRemoved(Game: Node): Game.ShopScreen.CharmLimit -= 2
