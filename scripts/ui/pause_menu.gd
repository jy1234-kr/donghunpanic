extends Control

signal resume_requested
signal save_requested(slot: int)
signal quit_to_menu

@onready var panel: Panel = $Panel
@onready var sens_slider: HSlider = $Panel/VBox/SensSlider
@onready var volume_slider: HSlider = $Panel/VBox/VolumeSlider


func _ready() -> void:
	visible = false
	var font: Font = load("res://assets/fonts/NotoSansKR-Regular.ttf")
	$Panel/VBox/Title.add_theme_font_override("font", font)
	$Panel/VBox/SensLabel.add_theme_font_override("font", font)
	$Panel/VBox/VolumeLabel.add_theme_font_override("font", font)
	$Panel/VBox/ResumeButton.add_theme_font_override("font", font)
	$Panel/VBox/SaveButton.add_theme_font_override("font", font)
	$Panel/VBox/MenuButton.add_theme_font_override("font", font)
	sens_slider.value = SaveManager.mouse_sensitivity * 1000.0
	volume_slider.value = SaveManager.master_volume * 100.0
	sens_slider.value_changed.connect(_on_sens_changed)
	volume_slider.value_changed.connect(_on_volume_changed)


func toggle() -> void:
	visible = not visible
	get_tree().paused = visible
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_sens_changed(value: float) -> void:
	SaveManager.mouse_sensitivity = value / 1000.0
	SaveManager.save_settings()


func _on_volume_changed(value: float) -> void:
	SaveManager.master_volume = value / 100.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(SaveManager.master_volume))
	SaveManager.save_settings()


func _on_resume_pressed() -> void:
	toggle()
	resume_requested.emit()


func _on_save_pressed() -> void:
	SaveManager.save_slot(0)
	get_tree().call_group("hud", "show_message", "저장 완료 (슬롯 1)", 2.0)


func _on_menu_pressed() -> void:
	get_tree().paused = false
	quit_to_menu.emit()
