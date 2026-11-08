class_name RouletteWheel
extends Node2D

signal BallLanded(BallIndex: int, Pocket: PocketData, Context: Dictionary)
signal SpinFinished(Results: Array[PocketData])

@export var Radius = 450.0
@export var BallCount = 1
@export var SpinTime = 3
@export var BallCooldown = 0.1

var Source: PocketSet = PocketSet.new(): 
    set(Value):
        if Source != null && Source.Changed.is_connected(queue_redraw): Source.Changed.disconnect(queue_redraw)
        Source = Value
        Source.Changed.connect(queue_redraw)
        queue_redraw()

var Pockets: Array[PocketData]:
    get: return Source.Pockets

var History: Array[PocketData]:
    get: return Source.History

var ColorTable: Dictionary:
    get: return Source.ColorTable

var _Balls: Array = []
var Luck = LuckSystem.new()
var RNG = GameState.RNG
var Spinning = false

func AddNumber(Number: int, ColorID: StringName, Weight = 1.0): return Source.AddNumber(Number, ColorID, Weight)
func AddPocket(Pocket: PocketData, Index = -1): Source.AddPocket(Pocket, Index)
func RemovePocket(Index: int): Source.RemovePocket(Index)

func Spin():
    if Spinning || Pockets.is_empty(): return

    Spinning = true
    _Balls.clear()
    var Slice = TAU / Pockets.size()
    var TotalTime = SpinTime + BallCooldown * (BallCount - 1)
    var Results: Array[PocketData] = []
    var Inner = Radius * 0.65
    var Outer = Radius * 0.95
    var NewTween = create_tween().set_parallel(true)

    NewTween.tween_property(self, "rotation", rotation + TAU * 3, TotalTime) \
	.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

    for i in BallCount:
        var Target = Luck.Pick(Pockets, RNG)
        var Ball = {"Angle": 0.0, "Radius": Outer}
        var StartAngle = RNG.randf() * TAU
        var FinalAngle = (Target + 0.5) * Slice - TAU * RNG.randi_range(4, 6)
        var Delay = i * BallCooldown

        _Balls.append(Ball)
        NewTween.tween_method(func(T: float):
            Ball.Angle = lerpf(StartAngle, FinalAngle, T)
            Ball.Radius = lerpf(Outer, Inner, pow(T, 3.0))
            queue_redraw(), 0.0, 1.0, SpinTime) \
		    .set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT).set_delay(Delay)
        NewTween.tween_callback(_Land.bind(i, Target, Results)).set_delay(Delay + SpinTime)

    await NewTween.finished
    Spinning = false
    SpinFinished.emit(Results)

func _Land(BallIndex: int, PocketIndex: int, Results: Array[PocketData]):
    var Pocket = Pockets[PocketIndex]
    var Context = {"Pocket": Pocket, "History": History, "Bonus": 0.0, "Wheel": self, "BallIndex": BallIndex}

    for Effect in Pocket.Effects: Effect.OnLand(Context)
    History.append(Pocket)
    Results.append(Pocket)
    BallLanded.emit(BallIndex, Pocket, Context)

func _draw() -> void:
    if Pockets.is_empty(): return

    var TextFont = ThemeDB.fallback_font
    var Slice = TAU / Pockets.size()

    for i in Pockets.size():
        var A0 = i * Slice
        var Mid = A0 + Slice * 0.5
        var PTS = PackedVector2Array([Vector2.ZERO])

        for S in 9: PTS.append(Vector2.from_angle(A0 + Slice * S / 8.0) * Radius)
        draw_colored_polygon(PTS, ColorTable.get(Pockets[i].ColorID, Color.GRAY))
        draw_line(Vector2.ZERO, Vector2.from_angle(A0) * Radius, Color.from_rgba8(255, 255, 255, 90), 2.0)
        draw_set_transform(Vector2.from_angle(Mid) * Radius * 0.85, Mid + PI / 2.0)
        draw_string(TextFont, Vector2(-15, 5), str(Pockets[i].Number), HORIZONTAL_ALIGNMENT_CENTER, 30, 20)
        draw_set_transform(Vector2.ZERO, 0.0)
        draw_circle(Vector2.ZERO, Radius * 0.45, Color("111111"))
    for B in _Balls: draw_circle(Vector2.from_angle(B.Angle) * B.Radius, Radius * 0.035, Color.WHITE)

func _ready() -> void: if not Source.Changed.is_connected(queue_redraw): Source.Changed.connect(queue_redraw)