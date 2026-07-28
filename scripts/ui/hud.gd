extends Control

@onready var panic_bar: ProgressBar = $Margin/VBox/PanicBar
@onready var panic_label: Label = $Margin/VBox/PanicLabel
@onready var objective_label: Label = $Margin/VBox/ObjectiveLabel
@onready var zone_label: Label = $Margin/VBox/ZoneLabel
@onready var prompt_label: Label = $Margin/VBox/PromptLabel
@onready var message_label: Label = $Margin/VBox/MessageLabel
@onready var inventory_label: Label = $Margin/VBox/InventoryLabel
@onready var portrait: TextureRect = $Portrait

var _message_timer: float = 0.0
var _font: Font


func _ready() -> void:
	add_to_group("hud")
	_font = load("res://assets/fonts/NotoSansKR-Regular.ttf")
	_apply_fonts()
	portrait.texture = load("res://assets/characters/donghun_face.png")
	PanicManager.panic_changed.connect(_on_panic_changed)
	GameState.objective_changed.connect(_on_objective_changed)
	GameState.item_added.connect(_update_inventory)
	_on_panic_changed(PanicManager.level, "")
	_on_objective_changed(GameState.objective)
	_update_inventory("")
	_update_zone()


func _process(delta: float) -> void:
	if _message_timer > 0:
		_message_timer -= delta
		if _message_timer <= 0:
			message_label.text = ""


func _apply_fonts() -> void:
	for label in [panic_label, objective_label, zone_label, prompt_label, message_label, inventory_label]:
		label.add_theme_font_override("font", _font)


func _on_panic_changed(level: float, reason: String) -> void:
	var previous := panic_bar.value
	panic_bar.value = level
	var color := Color(0.2, 0.8, 0.3)
	if level > 50:
		color = Color(0.9, 0.7, 0.1)
	if level > 75:
		color = Color(0.9, 0.2, 0.1)
	panic_bar.modulate = color
	panic_label.text = "패닉: %d%%" % int(level)
	if reason != "":
		show_message(reason, 2.5)
	if level > 80:
		modulate = Color(1.15, 0.75, 0.75)
		if previous <= 80 and level > 80:
			AudioManager.play_panic_pulse()
	elif GameState.is_dark_zone():
		modulate = Color(0.75, 0.78, 0.9)
	else:
		modulate = Color.WHITE


func _on_objective_changed(text: String) -> void:
	objective_label.text = "목표: " + text


func set_prompt(text: String) -> void:
	prompt_label.text = text


func show_message(text: String, duration: float = 3.0) -> void:
	message_label.text = text
	_message_timer = duration


func _update_inventory(_item: String) -> void:
	var names: Array[String] = []
	var items_data: Dictionary = _load_items()
	for item_id in GameState.inventory:
		var entry: Dictionary = items_data.get(item_id, {})
		names.append(entry.get("name", item_id))
	inventory_label.text = "소지품: " + (", ".join(names) if names.size() > 0 else "없음")


func _update_zone() -> void:
	zone_label.text = "위치: " + GameState.get_zone_display_name()


func refresh_zone() -> void:
	_update_zone()


func _load_items() -> Dictionary:
	var file := FileAccess.open("res://data/items.json", FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}
