extends Control

signal dialogue_finished

@onready var panel: Panel = $Panel
@onready var speaker_label: Label = $Panel/VBox/Speaker
@onready var text_label: Label = $Panel/VBox/Text
@onready var continue_hint: Label = $Panel/VBox/Hint

var _lines: Array = []
var _index: int = 0
var _font: Font
var _dialogue_data: Dictionary = {}


func _ready() -> void:
	visible = false
	_font = load("res://assets/fonts/NotoSansKR-Regular.ttf")
	for node in [speaker_label, text_label, continue_hint]:
		node.add_theme_font_override("font", _font)
	_load_dialogue()


func show_dialogue(key: String) -> void:
	if not _dialogue_data.has(key):
		return
	var entry: Dictionary = _dialogue_data[key]
	_lines = entry.get("lines", [])
	_index = 0
	visible = true
	_show_line()


func _show_line() -> void:
	if _index >= _lines.size():
		visible = false
		dialogue_finished.emit()
		return
	var line: Dictionary = _lines[_index]
	speaker_label.text = line.get("speaker", "")
	text_label.text = line.get("text", "")
	continue_hint.text = "클릭 또는 E — 다음"


func advance() -> void:
	if not visible:
		return
	_index += 1
	AudioManager.play_ui_click()
	_show_line()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact") or (event is InputEventMouseButton and event.pressed):
		advance()
		get_viewport().set_input_as_handled()


func _load_dialogue() -> void:
	var file := FileAccess.open("res://data/dialogue_ko.json", FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		_dialogue_data = parsed
