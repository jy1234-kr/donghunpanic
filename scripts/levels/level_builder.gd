extends Node3D

const PS1_SHADER := preload("res://shaders/ps1_snap.gdshader")

const COLORS := {
	"floor": Color(0.55, 0.45, 0.35),
	"wall": Color(0.82, 0.78, 0.68),
	"ceiling": Color(0.92, 0.92, 0.88),
	"chalkboard": Color(0.15, 0.45, 0.2),
	"desk": Color(0.45, 0.3, 0.18),
	"metal": Color(0.6, 0.62, 0.65),
	"grass": Color(0.25, 0.55, 0.2),
	"sky": Color(0.55, 0.75, 0.95),
	"wood": Color(0.5, 0.35, 0.22),
	"screen": Color(0.1, 0.12, 0.15),
}


func build_zone(zone: String, root: Node3D) -> Vector3:
	match zone:
		"classroom":
			return _build_classroom(root)
		"hallway":
			return _build_hallway(root)
		"computer_lab":
			return _build_computer_lab(root)
		"library":
			return _build_library(root)
		"office":
			return _build_office(root)
		"cafeteria":
			return _build_cafeteria(root)
		"playground":
			return _build_playground(root)
	return Vector3.ZERO


func _build_classroom(root: Node3D) -> Vector3:
	_add_room(root, Vector3(14, 4, 16), Vector3.ZERO)
	_add_box(root, Vector3(6, 2.5, 0.2), Vector3(0, 1.5, -7.8), COLORS.chalkboard)
	for x in [-4, -2, 0, 2, 4]:
		for z in [-2, 1, 4]:
			_add_box(root, Vector3(1.2, 0.8, 0.8), Vector3(x, 0.4, z), COLORS.desk)
	_add_box(root, Vector3(2, 0.9, 1), Vector3(0, 0.45, 7), COLORS.desk)
	_add_laptop(root, Vector3(0, 1.0, 7))
	_add_portal(root, Vector3(0, 1.5, 7.9), Vector3(2, 3, 0.5), "hallway", "from_class", "복도로 [E]", "can_leave_class", "발표 자료를 찾기 전엔 못 나갑니다!")
	_add_label(root, "2-A 교실", Vector3(0, 3.2, -6))
	return Vector3(0, 1.0, 5)


func _build_hallway(root: Node3D) -> Vector3:
	_add_room(root, Vector3(8, 4, 40), Vector3.ZERO)
	_add_portal(root, Vector3(0, 1.5, 18), Vector3(3, 3, 1), "classroom", "from_hall", "교실 [E]")
	_add_portal(root, Vector3(-3.5, 1.5, 0), Vector3(1, 3, 3), "computer_lab", "default", "컴퓨터실 [E]")
	_add_portal(root, Vector3(3.5, 1.5, 0), Vector3(1, 3, 3), "library", "default", "도서관 [E]")
	_add_portal(root, Vector3(0, 1.5, -8), Vector3(3, 3, 1), "office", "default", "교무실 [E]")
	_add_portal(root, Vector3(0, 1.5, -18), Vector3(3, 3, 1), "cafeteria", "default", "급식실 [E]")
	_add_portal(root, Vector3(0, 1.5, -28), Vector3(4, 3, 1), "playground", "default", "운동장 [E]")
	_add_label(root, "중앙 복도", Vector3(0, 3.2, 10))
	return Vector3(0, 1.0, 15)


func _build_computer_lab(root: Node3D) -> Vector3:
	_add_room(root, Vector3(16, 4, 14), Vector3(-20, 0, 0))
	for i in 4:
		_add_box(root, Vector3(1.5, 0.8, 1), Vector3(-23 + i * 3, 0.4, -2), COLORS.metal)
		_add_box(root, Vector3(0.8, 0.6, 0.1), Vector3(-23 + i * 3, 1.0, -2.4), COLORS.screen)
	_add_interact(root, Vector3(-20, 1, 2), Vector3(2, 2, 2), "cached_ppt", "캐시된 PPT 찾기 [E]", _on_cached_ppt)
	_add_portal(root, Vector3(7.5, 1.5, 0), Vector3(1, 3, 3), "hallway", "lab_door", "복도 [E]")
	_add_label(root, "컴퓨터실", Vector3(-20, 3.2, -5))
	return Vector3(-18, 1.0, 5)


func _build_library(root: Node3D) -> Vector3:
	_add_room(root, Vector3(16, 4, 14), Vector3(20, 0, 0))
	for i in 5:
		_add_box(root, Vector3(0.4, 2, 4), Vector3(14 + i * 1.5, 1, 0), COLORS.wood)
	_add_interact(root, Vector3(24, 1, 3), Vector3(2, 2, 2), "printed_notes", "인쇄본 찾기 [E]", _on_printed_notes)
	_add_portal(root, Vector3(12.5, 1.5, 0), Vector3(1, 3, 3), "hallway", "library_door", "복도 [E]")
	_add_label(root, "도서관", Vector3(20, 3.2, -5))
	return Vector3(22, 1.0, 5)


func _build_office(root: Node3D) -> Vector3:
	_add_room(root, Vector3(12, 4, 12), Vector3(0, 0, -30))
	_add_box(root, Vector3(2.5, 0.9, 1.2), Vector3(0, 0.45, -4), COLORS.desk)
	_add_interact(root, Vector3(0, 1, -4), Vector3(2, 2, 2), "teacher_password", "교사 계정 메모 [E]", _on_teacher_password)
	_add_portal(root, Vector3(0, 1.5, 5.5), Vector3(3, 3, 1), "hallway", "office_door", "복도 [E]")
	_add_label(root, "교무실", Vector3(0, 3.2, -2))
	return Vector3(0, 1.0, 3)


func _build_cafeteria(root: Node3D) -> Vector3:
	_add_room(root, Vector3(18, 4, 14), Vector3(0, 0, -48))
	for x in [-5, 0, 5]:
		_add_box(root, Vector3(3, 0.8, 1), Vector3(x, 0.4, 0), COLORS.metal)
	_add_interact(root, Vector3(5, 1, -3), Vector3(2, 2, 2), "water", "물 마시기 [E]", _on_drink_water)
	_add_interact(root, Vector3(-5, 1, 2), Vector3(2, 2, 2), "usb_backup", "친구 USB [E]", _on_usb_backup)
	_add_portal(root, Vector3(0, 1.5, 6.5), Vector3(4, 3, 1), "hallway", "cafe_door", "복도 [E]")
	_add_label(root, "급식실", Vector3(0, 3.2, -4))
	return Vector3(0, 1.0, 3)


func _build_playground(root: Node3D) -> Vector3:
	_add_box(root, Vector3(40, 0.2, 40), Vector3(0, 0, -70), COLORS.grass)
	_add_box(root, Vector3(40, 8, 0.2), Vector3(0, 4, -90), COLORS.sky)
	for side in [-1, 1]:
		_add_box(root, Vector3(0.2, 3, 40), Vector3(side * 20, 1.5, -70), COLORS.wall)
	_add_portal(root, Vector3(0, 1.5, -52), Vector3(4, 3, 1), "hallway", "playground_door", "복도 [E]")
	_add_interact(root, Vector3(0, 1, -75), Vector3(4, 3, 4), "flee", "도망치기 [E]", _on_flee_ending)
	_add_label(root, "운동장", Vector3(0, 4, -65))
	return Vector3(0, 1.0, -58)


func _add_room(root: Node3D, size: Vector3, center: Vector3) -> void:
	_add_box(root, Vector3(size.x, 0.2, size.z), center + Vector3(0, -0.1, 0), COLORS.floor)
	_add_box(root, Vector3(size.x, 0.2, size.z), center + Vector3(0, size.y - 0.1, 0), COLORS.ceiling)
	_add_box(root, Vector3(size.x, size.y, 0.2), center + Vector3(0, size.y * 0.5, -size.z * 0.5), COLORS.wall)
	_add_box(root, Vector3(size.x, size.y, 0.2), center + Vector3(0, size.y * 0.5, size.z * 0.5), COLORS.wall)
	_add_box(root, Vector3(0.2, size.y, size.z), center + Vector3(-size.x * 0.5, size.y * 0.5, 0), COLORS.wall)
	_add_box(root, Vector3(0.2, size.y, size.z), center + Vector3(size.x * 0.5, size.y * 0.5, 0), COLORS.wall)


func _add_box(root: Node3D, size: Vector3, pos: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = pos
	body.collision_layer = 1
	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.material_override = _make_material(color)
	body.add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	root.add_child(body)
	return body


func _add_laptop(root: Node3D, pos: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	body.collision_layer = 1
	var base := MeshInstance3D.new()
	var base_mesh := BoxMesh.new()
	base_mesh.size = Vector3(0.8, 0.05, 0.55)
	base.mesh = base_mesh
	base.material_override = _make_material(COLORS.metal)
	body.add_child(base)
	var screen := MeshInstance3D.new()
	var screen_mesh := BoxMesh.new()
	screen_mesh.size = Vector3(0.75, 0.45, 0.03)
	screen.mesh = screen_mesh
	screen.position = Vector3(0, 0.25, -0.22)
	screen.rotation_degrees.x = -15
	screen.material_override = _make_material(COLORS.screen)
	body.add_child(screen)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1, 1, 1)
	collision.shape = shape
	body.add_child(collision)
	root.add_child(body)

	var interact := Area3D.new()
	interact.position = pos
	interact.set_script(load("res://scripts/systems/interactable.gd"))
	interact.prompt_text = "노트북 열기 [E]"
	interact.interaction_id = "laptop"
	interact.collision_layer = 0
	interact.collision_mask = 2
	var col := CollisionShape3D.new()
	var col_shape := BoxShape3D.new()
	col_shape.size = Vector3(1.2, 1.2, 1.2)
	col.shape = col_shape
	interact.add_child(col)
	interact.interacted.connect(_on_laptop_interact)
	root.add_child(interact)


func _add_portal(root: Node3D, pos: Vector3, size: Vector3, zone: String, spawn: String, prompt: String, req_flag: String = "", blocked: String = "") -> void:
	var portal := Area3D.new()
	portal.position = pos
	portal.set_script(load("res://scripts/systems/portal.gd"))
	portal.target_zone = zone
	portal.target_spawn = spawn
	portal.prompt_text = prompt
	portal.requires_flag = req_flag
	portal.blocked_message = blocked
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	portal.add_child(col)
	root.add_child(portal)


func _add_interact(root: Node3D, pos: Vector3, size: Vector3, id: String, prompt: String, callback: Callable) -> void:
	var interact := Area3D.new()
	interact.position = pos
	interact.set_script(load("res://scripts/systems/interactable.gd"))
	interact.prompt_text = prompt
	interact.interaction_id = id
	interact.one_shot = true
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	interact.add_child(col)
	interact.interacted.connect(callback)
	root.add_child(interact)


func _add_label(root: Node3D, text: String, pos: Vector3) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = pos
	label.font_size = 48
	label.modulate = Color(1, 0.95, 0.7)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(label)


func _make_material(color: Color) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = PS1_SHADER
	mat.set_shader_parameter("albedo_color", color)
	return mat


func _on_laptop_interact(_player: Node3D) -> void:
	if GameState.current_zone == "classroom" and GameState.can_present():
		get_tree().call_group("game_root", "start_final_presentation")
	else:
		get_tree().call_group("game_root", "open_google_login")


func _on_cached_ppt(_player: Node3D) -> void:
	if GameState.has_item("cached_ppt"):
		return
	GameState.collect_backup("cached_ppt")
	GameState.set_chapter(2)
	AudioManager.play_item_pickup()
	get_tree().call_group("game_root", "show_dialogue", "it_teacher_intro")


func _on_printed_notes(_player: Node3D) -> void:
	if GameState.has_item("printed_notes"):
		return
	GameState.collect_backup("printed_notes")
	GameState.set_chapter(3)
	AudioManager.play_item_pickup()
	get_tree().call_group("game_root", "show_dialogue", "library_find")


func _on_teacher_password(_player: Node3D) -> void:
	if GameState.has_item("teacher_password"):
		return
	GameState.collect_backup("teacher_password")
	GameState.set_chapter(4)
	PanicManager.add_panic(10.0, "몰래 계정 정보 훔침")
	AudioManager.play_item_pickup()
	get_tree().call_group("game_root", "show_dialogue", "office_sneak")


func _on_usb_backup(_player: Node3D) -> void:
	if GameState.has_item("usb_backup"):
		return
	GameState.collect_backup("usb_backup")
	AudioManager.play_item_pickup()
	get_tree().call_group("game_root", "show_dialogue", "friend_usb")


func _on_drink_water(_player: Node3D) -> void:
	PanicManager.reduce_panic(15.0, "물 한 모금")
	get_tree().call_group("game_root", "show_message", "시원한 물... 패닉이 조금 가라앉았다.")


func _on_flee_ending(_player: Node3D) -> void:
	GameState.trigger_ending("flee")
