class_name Orbit
extends CharmData

func OnAdded(Game: Node): Game.SpinsGiven += 2
func OnRemoved(Game: Node): Game.SpinsGiven -= 2
