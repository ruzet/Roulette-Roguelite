class_name RedTie
extends CharmData

func OnAdded(Game: Node): Game.Book.AddColorPayout(self, &"Red", 1.5)
func OnRemoved(Game: Node): Game.Book.RemovePayoutSource(self)