class_name BlackTie
extends CharmData

func OnAdded(Game: Node): Game.Book.AddColorPayout(self, &"Black", 1.5)
func OnRemoved(Game: Node): Game.Book.RemovePayoutSource(self)