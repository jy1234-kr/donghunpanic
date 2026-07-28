extends Node

signal chapter_changed(chapter: int)
signal flag_changed(flag: String, value: bool)
signal item_added(item_id: String)
signal item_removed(item_id: String)
signal ending_triggered(ending_id: String)
signal objective_changed(text: String)

var chapter: int = 0
var current_zone: String = "floor2_classroom"
var spawn_point: String = "default"
var flags: Dictionary = {}
var inventory: Array[String] = []
var objective: String = "교탁 앞 노트북으로 발표 자료를 여세요."

const ZONE_NAMES: Dictionary = {
	"floor2_classroom": "2층 2-A 교실",
	"floor2_hallway": "2층 복도",
	"floor1_cafeteria": "1층 급식실",
	"floor1_lobby": "1층 현관 (어두움)",
	"floor3_computer_lab": "3층 컴퓨터실",
	"floor3_library": "3층 도서관",
	"floor4_office": "4층 교무실",
	"floor4_dark_hall": "4층 어두운 복도",
	"floor5_storage": "5층 폐창고",
	"floor5_rooftop": "5층 옥상",
	"stairwell_f1": "1층 계단",
	"stairwell_f2": "2층 계단",
	"stairwell_f3": "3층 계단",
	"stairwell_f4": "4층 계단",
	"stairwell_f5": "5층 계단",
}

const DARK_ZONES: Array[String] = [
	"floor1_lobby",
	"floor4_dark_hall",
	"floor5_storage",
	"floor5_rooftop",
	"stairwell_f4",
	"stairwell_f5",
]


func _ready() -> void:
	reset_game()


func reset_game() -> void:
	chapter = 0
	current_zone = "floor2_classroom"
	spawn_point = "default"
	flags.clear()
	inventory.clear()
	objective = "교탁 앞 노트북으로 발표 자료를 여세요."
	set_flag("prologue_started", false)
	set_flag("login_failed", false)
	set_flag("can_leave_class", false)
	set_flag("presentation_ready", false)
	PanicManager.reset()


func set_chapter(value: int) -> void:
	chapter = value
	chapter_changed.emit(chapter)


func set_flag(flag: String, value: bool = true) -> void:
	flags[flag] = value
	flag_changed.emit(flag, value)


func has_flag(flag: String) -> bool:
	return flags.get(flag, false)


func add_item(item_id: String) -> void:
	if item_id in inventory:
		return
	inventory.append(item_id)
	item_added.emit(item_id)
	_check_item_objectives(item_id)


func remove_item(item_id: String) -> void:
	if item_id in inventory:
		inventory.erase(item_id)
		item_removed.emit(item_id)


func has_item(item_id: String) -> bool:
	return item_id in inventory


func set_objective(text: String) -> void:
	objective = text
	objective_changed.emit(text)


func change_zone(zone: String, spawn: String = "default") -> void:
	current_zone = zone
	spawn_point = spawn


func is_dark_zone() -> bool:
	return current_zone in DARK_ZONES


func get_zone_display_name() -> String:
	return ZONE_NAMES.get(current_zone, current_zone)


func trigger_ending(ending_id: String) -> void:
	if has_flag("ending_triggered"):
		return
	set_flag("ending_triggered")
	ending_triggered.emit(ending_id)


func start_prologue() -> void:
	if has_flag("prologue_started"):
		return
	set_flag("prologue_started")
	set_chapter(0)
	set_objective("노트북을 조사해서 Google Drive 발표 자료를 여세요.")


func on_login_failed() -> void:
	set_flag("login_failed")
	set_flag("can_leave_class")
	set_chapter(1)
	PanicManager.add_panic(25.0, "Google 로그인 실패")
	set_objective("학교를 돌며 자료를 구하세요. 4~5층은 불이 꺼져 있습니다.")


func collect_backup(item_id: String) -> void:
	add_item(item_id)
	match item_id:
		"usb_backup":
			set_objective("USB를 얻었습니다. 2층 교실로 돌아가 발표하세요.")
		"printed_notes":
			set_objective("인쇄본을 얻었습니다. 2층 교실로 돌아가 발표하세요.")
		"cached_ppt":
			set_objective("캐시 PPT를 찾았습니다. 2층 교실로 돌아가 발표하세요.")
		"teacher_password":
			set_objective("교사 계정 정보를 얻었습니다. 교실 노트북에 로그인하세요.")


func can_present() -> bool:
	return has_item("usb_backup") or has_item("printed_notes") or has_item("cached_ppt") or has_item("teacher_password")


func _check_item_objectives(item_id: String) -> void:
	if can_present():
		set_flag("presentation_ready")


func get_save_data() -> Dictionary:
	return {
		"chapter": chapter,
		"current_zone": current_zone,
		"spawn_point": spawn_point,
		"flags": flags.duplicate(),
		"inventory": inventory.duplicate(),
		"objective": objective,
		"panic": PanicManager.level,
	}


func load_save_data(data: Dictionary) -> void:
	chapter = int(data.get("chapter", 0))
	current_zone = str(data.get("current_zone", "floor2_classroom"))
	spawn_point = str(data.get("spawn_point", "default"))
	flags = data.get("flags", {}).duplicate()
	inventory.assign(data.get("inventory", []))
	objective = str(data.get("objective", objective))
	PanicManager.level = float(data.get("panic", 0.0))
	chapter_changed.emit(chapter)
	objective_changed.emit(objective)
