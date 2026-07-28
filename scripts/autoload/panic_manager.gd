extends Node

signal panic_changed(level: float, reason: String)
signal panic_max_reached

var level: float = 0.0
var passive_rate: float = 0.15
var running: bool = false

const PANIC_MAX: float = 100.0


func _ready() -> void:
	set_process(true)


func _process(delta: float) -> void:
	if level >= PANIC_MAX:
		return
	if GameState.has_flag("ending_triggered"):
		return
	var rate := passive_rate
	if running:
		rate += 0.35
	if GameState.chapter >= 1:
		add_panic(rate * delta, "")


func reset() -> void:
	level = 0.0
	running = false
	panic_changed.emit(level, "reset")


func add_panic(amount: float, reason: String) -> void:
	if amount <= 0.0 and reason == "":
		return
	if GameState.has_flag("ending_triggered"):
		return
	var previous := level
	level = clampf(level + amount, 0.0, PANIC_MAX)
	if not is_equal_approx(previous, level) or reason != "":
		panic_changed.emit(level, reason)
	if level >= PANIC_MAX and previous < PANIC_MAX:
		panic_max_reached.emit()
		GameState.trigger_ending("meltdown")


func reduce_panic(amount: float, reason: String) -> void:
	add_panic(-absf(amount), reason)


func set_running(is_running: bool) -> void:
	running = is_running
	if is_running and GameState.chapter >= 1:
		add_panic(0.5, "달리는 중...")
