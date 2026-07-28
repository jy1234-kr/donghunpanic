extends Control

signal finished

@onready var photo: TextureRect = $Photo
@onready var flash: ColorRect = $Flash
@onready var vignette: ColorRect = $Vignette
@onready var title: Label = $Title
@onready var subtitle: Label = $Subtitle

var _time: float = 0.0
var _font: Font


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font = load("res://assets/fonts/NotoSansKR-Regular.ttf")
	title.add_theme_font_override("font", _font)
	subtitle.add_theme_font_override("font", _font)
	photo.texture = load("res://assets/characters/donghun_face.png")
	vignette.color = Color(0.3, 0, 0, 0)


func play() -> void:
	visible = true
	_time = 0.0
	title.modulate.a = 0.0
	subtitle.modulate.a = 0.0
	photo.scale = Vector2(1.8, 1.8)
	photo.pivot_offset = photo.size * 0.5
	await get_tree().process_frame
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(photo, "scale", Vector2(1.0, 1.0), 1.8).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(vignette, "color:a", 0.75, 1.2)
	tween.tween_property(title, "modulate:a", 1.0, 0.6).set_delay(0.4)
	tween.tween_property(subtitle, "modulate:a", 1.0, 0.6).set_delay(0.8)
	for i in 6:
		await get_tree().create_timer(0.18).timeout
		flash.modulate.a = 0.35
		AudioManager.play_panic_pulse()
		await get_tree().create_timer(0.08).timeout
		flash.modulate.a = 0.0
		photo.position += Vector2(randf_range(-6, 6), randf_range(-6, 6))
	await get_tree().create_timer(1.2).timeout
	var fade := create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.8)
	await fade.finished
	photo.position = Vector2.ZERO
	photo.scale = Vector2.ONE
	visible = false
	modulate.a = 1.0
	finished.emit()
