class_name Outreach
extends CharmData

func OnAdded(Game: Node): 
    Game.ShopScreen.OfferCount += 3
    Game.ShopScreen.CharmOfferCount += 1

func OnRemoved(Game: Node): 
    Game.ShopScreen.OfferCount -= 3
    Game.ShopScreen.CharmOfferCount -= 1