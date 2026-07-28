extends Control

@onready var title: Label = $VBox/Title
@onready var subtitle: Label = $VBox/Subtitle


func _ready() -> void:
	var font: Font = load("res://assets/fonts/NotoSansKR-Regular.ttf")
	title.add_theme_font_override("font", font)
	subtitle.add_theme_font_override("font", font)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_new_game_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/main/game.tscn")


func _on_continue_pressed() -> void:
	if SaveManager.load_slot(0):
		AudioManager.play_ui_click()
		get_tree().change_scene_to_file("res://scenes/main/game.tscn")
	else:
		subtitle.text = "저장 파일이 없습니다."


func _on_quit_pressed() -> void:
	get_tree().quit()
