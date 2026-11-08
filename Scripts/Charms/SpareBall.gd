class_name SpareBall
extends CharmData

func OnAdded(Game: Node): Game.Wheel.BallCount += 1
func OnRemoved(Game: Node): Game.Wheel.BallCount -= 1