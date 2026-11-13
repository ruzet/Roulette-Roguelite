class_name Outreach
extends CharmData

func OnAdded(Game: Node): 
	Game.ShopScreen.OfferCount += 2
	Game.ShopScreen.CharmOfferCount += 1

func OnRemoved(Game: Node): 
	Game.ShopScreen.OfferCount -= 2
	Game.ShopScreen.CharmOfferCount -= 1
