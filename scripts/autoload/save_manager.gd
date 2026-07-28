extends Node

const SAVE_PATH := "user://donghunpanic_save_%d.json"
const SETTINGS_PATH := "user://donghunpanic_settings.json"

var mouse_sensitivity: float = 0.0025
var master_volume: float = 0.8
var fullscreen: bool = false
var pending_load: bool = false


func _ready() -> void:
	load_settings()


func save_slot(slot: int) -> bool:
	var data := {
		"version": 1,
		"timestamp": Time.get_unix_time_from_system(),
		"game": GameState.get_save_data(),
	}
	var path := SAVE_PATH % slot
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	return true


func load_slot(slot: int) -> bool:
	var path := SAVE_PATH % slot
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var game_data: Dictionary = parsed.get("game", {})
	GameState.load_save_data(game_data)
	pending_load = true
	return true


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_PATH % slot)


func delete_save(slot: int) -> void:
	var path := SAVE_PATH % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func save_settings() -> void:
	var data := {
		"mouse_sensitivity": mouse_sensitivity,
		"master_volume": master_volume,
		"fullscreen": fullscreen,
	}
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))


func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	mouse_sensitivity = float(parsed.get("mouse_sensitivity", mouse_sensitivity))
	master_volume = float(parsed.get("master_volume", master_volume))
	fullscreen = bool(parsed.get("fullscreen", fullscreen))
	_apply_settings()


func _apply_settings() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
