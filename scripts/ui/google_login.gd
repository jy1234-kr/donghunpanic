extends Control

signal login_completed(success: bool)

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/VBox/Title
@onready var status_label: Label = $Panel/VBox/Status
@onready var email_input: LineEdit = $Panel/VBox/EmailInput
@onready var password_input: LineEdit = $Panel/VBox/PasswordInput
@onready var action_button: Button = $Panel/VBox/ActionButton
@onready var captcha_label: Label = $Panel/VBox/CaptchaLabel

var _step: int = 0
var _font: Font

const STEPS := [
	{"title": "Google 로그인", "status": "발표 자료 Drive를 열려면 로그인하세요.", "button": "다음"},
	{"title": "비밀번호 확인", "status": "비밀번호를 입력하세요.", "button": "로그인"},
	{"title": "2단계 인증", "status": "휴대폰으로 전송된 코드를 입력하세요.", "button": "확인"},
	{"title": "CAPTCHA", "status": "아래 교통 표지판을 모두 선택하세요.", "button": "제출"},
	{"title": "Drive 접근 거부", "status": "이 계정은 조직 정책으로 Drive에 접근할 수 없습니다.", "button": "..."},
]


func _ready() -> void:
	visible = false
	_font = load("res://assets/fonts/NotoSansKR-Regular.ttf")
	for node in [title_label, status_label, captcha_label]:
		node.add_theme_font_override("font", _font)
	email_input.add_theme_font_override("font", _font)
	password_input.add_theme_font_override("font", _font)
	action_button.pressed.connect(_on_action_pressed)


func open_login() -> void:
	visible = true
	_step = 0
	email_input.text = "donghun.student@gmail.com"
	password_input.text = ""
	_update_step()


func _update_step() -> void:
	var data: Dictionary = STEPS[_step]
	title_label.text = data.title
	status_label.text = data.status
	action_button.text = data.button
	captcha_label.visible = _step == 3
	if _step == 3:
		captcha_label.text = "[ 🚦 🚌 🚗 ]  ← 이 중 교통 표지판은?"
	password_input.visible = _step in [1, 2]
	email_input.visible = _step == 0


func _on_action_pressed() -> void:
	AudioManager.play_ui_click()
	_step += 1
	if _step < STEPS.size():
		_update_step()
		if _step == 2:
			status_label.text = "코드가 틀렸습니다. 다시 입력하세요."
		return
	close_login(false)


func close_login(success: bool) -> void:
	visible = false
	login_completed.emit(success)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause"):
		close_login(false)
		get_viewport().set_input_as_handled()
