class_name PocketSet
extends RefCounted
signal Changed

var Pockets: Array[PocketData] = []
var History: Array[PocketData] = []
var ColorTable = {
    &"Red": Color.from_rgba8(180, 0, 0),
    &"Black": Color.from_rgba8(0, 0, 0),
    &"Green": Color.from_rgba8(0, 180, 0)
}

func AddNumber(Number: int, ColorID: StringName, Weight: float = 1.0):
    var Data = PocketData.new()
    Data.Number = Number
    Data.ColorID = ColorID
    Data.BaseWeight = Weight
    AddPocket(Data)
    return Data

func AddPocket(Data: PocketData, Index = -1):
    if Index < 0:
        Pockets.append(Data)
    else:
        Pockets.insert(Index, Data)
    Changed.emit()

func AddTemplate(Template: PocketTemplate):
    var Next = 0
    for Pocket in Pockets: Next = maxi(Next, Pocket.Number + 1)
    ColorTable[Template.ColorID] = Template.DisplayColor
    var Data = Template.Build(Next)
    AddPocket(Data)
    return Data

func RemovePocket(Index: int):
    Pockets.remove_at(Index)
    Changed.emit()

func Colors():
    var Output: Array[StringName] = []
    for Pocket in Pockets:
        if not Output.has(Pocket.ColorID):
            Output.append(Pocket.ColorID)
    return Output