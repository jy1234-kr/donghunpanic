extends Control

signal restart_requested
signal menu_requested

@onready var title_label: Label = $Panel/VBox/Title
@onready var desc_label: Label = $Panel/VBox/Description


func _ready() -> void:
	visible = false
	var font: Font = load("res://assets/fonts/NotoSansKR-Regular.ttf")
	for node in [title_label, desc_label]:
		node.add_theme_font_override("font", font)


func show_ending(ending_id: String) -> void:
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var endings := _load_endings()
	var data: Dictionary = endings.get(ending_id, {"title": ending_id, "description": ""})
	title_label.text = data.get("title", ending_id)
	desc_label.text = data.get("description", "")
	AudioManager.play_ending_stinger(ending_id)


func _load_endings() -> Dictionary:
	var file := FileAccess.open("res://data/endings.json", FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}


func _on_restart_pressed() -> void:
	restart_requested.emit()


func _on_menu_pressed() -> void:
	menu_requested.emit()
