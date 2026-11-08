class_name Cashback
extends CharmData

var _Game: Node

func OnAdded(Game: Node): 
    _Game = Game
    Game.SpinResolved.connect(_OnSpinResolved)

func OnRemoved(Game: Node): 
    if Game.SpinResolved.is_connected(_OnSpinResolved): Game.SpinResolved.disconnect(_OnSpinResolved)
    _Game = null

func _OnSpinResolved(Result: Dictionary):
    var Refund = roundi(Result.Staked * 0.15)
    if Refund:
        _Game.Book.Balance += Refund
        _Game.Book.Changed.emit()