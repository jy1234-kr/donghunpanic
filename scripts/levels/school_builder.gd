extends Node3D

const PS1_SHADER := preload("res://shaders/ps1_snap.gdshader")
const FLICKER_SCRIPT := preload("res://scripts/systems/flickering_light.gd")

const FLOOR_H := 4.0
const DONGHUN_TEX := preload("res://assets/characters/donghun_face.png")

const COLORS := {
	"floor": Color(0.35, 0.32, 0.28),
	"wall": Color(0.55, 0.52, 0.48),
	"ceiling": Color(0.45, 0.45, 0.42),
	"chalkboard": Color(0.08, 0.28, 0.12),
	"desk": Color(0.32, 0.22, 0.14),
	"metal": Color(0.4, 0.42, 0.45),
	"dark_wall": Color(0.12, 0.11, 0.14),
	"dark_floor": Color(0.08, 0.07, 0.09),
	"screen": Color(0.05, 0.06, 0.08),
	"wood": Color(0.35, 0.24, 0.16),
}

const SPAWNS: Dictionary = {
	"floor2_classroom": Vector3(0, 4.0, 9),
	"floor2_hallway": Vector3(0, 4.0, -2),
	"floor2_hallway_from_class": Vector3(0, 4.0, 10),
	"floor1_cafeteria": Vector3(-14, 1.0, 0),
	"floor1_lobby": Vector3(14, 1.0, 0),
	"floor3_computer_lab": Vector3(-14, 8.0, 0),
	"floor3_library": Vector3(14, 8.0, 0),
	"floor4_office": Vector3(0, 12.0, 10),
	"floor4_dark_hall": Vector3(0, 12.0, -8),
	"floor5_storage": Vector3(-10, 16.0, 0),
	"floor5_rooftop": Vector3(10, 16.0, -8),
	"stairwell_f1": Vector3(0, 1.0, -12),
	"stairwell_f2": Vector3(0, 5.0, -12),
	"stairwell_f3": Vector3(0, 9.0, -12),
	"stairwell_f4": Vector3(0, 13.0, -12),
	"stairwell_f5": Vector3(0, 17.0, -12),
}


func build_school(root: Node3D) -> void:
	for floor in range(1, 6):
		_build_stairwell(root, floor)
	_build_floor1(root)
	_build_floor2(root)
	_build_floor3(root)
	_build_floor4(root)
	_build_floor5(root)
	_spawn_panicking_donghun(root)


func get_spawn(spawn_id: String) -> Vector3:
	return SPAWNS.get(spawn_id, SPAWNS.get("floor2_classroom", Vector3(0, 4, 9)))


func has_spawn(spawn_id: String) -> bool:
	return SPAWNS.has(spawn_id)


func _build_floor2(root: Node3D) -> void:
	var y := FLOOR_H
	_add_room(root, Vector3(16, 3.8, 18), Vector3(0, y, 4), false, true)
	_add_box(root, Vector3(7, 2.2, 0.15), Vector3(0, y + 1.4, -4.8), COLORS.chalkboard)
	for x in [-5, -2.5, 0, 2.5, 5]:
		for z in [-1, 2, 5]:
			_add_box(root, Vector3(1.1, 0.75, 0.75), Vector3(x, y + 0.38, z), COLORS.desk)
	_add_box(root, Vector3(2, 0.85, 1), Vector3(0, y + 0.43, 8.5), COLORS.desk)
	_add_laptop(root, Vector3(0, y + 0.95, 8.5))
	_add_light(root, Vector3(0, y + 3.2, 4), 1.4, Color(1.0, 0.95, 0.85), 14.0)
	_add_light(root, Vector3(-4, y + 3.0, 0), 0.9, Color(1.0, 0.92, 0.8), 8.0)
	_add_light(root, Vector3(4, y + 3.0, 0), 0.9, Color(1.0, 0.92, 0.8), 8.0)
	_add_portal(root, Vector3(0, y + 1.5, 12.5), Vector3(2.5, 3, 0.6), "floor2_hallway", "from_class", "복도 [E]", "can_leave_class", "발표 자료를 찾기 전엔 못 나갑니다!")
	_add_label(root, "2층 2-A 교실", Vector3(0, y + 3.0, -3))

	_add_room(root, Vector3(10, 3.8, 14), Vector3(0, y, -10), false, true)
	_add_portal(root, Vector3(0, y + 1.5, -3.5), Vector3(3, 3, 1), "floor2_classroom", "default", "2-A 교실 [E]")
	_add_portal(root, Vector3(-4.5, y + 1.5, -10), Vector3(1.2, 3, 3), "floor3_computer_lab", "default", "3층 컴실 [E]")
	_add_portal(root, Vector3(4.5, y + 1.5, -10), Vector3(1.2, 3, 3), "floor3_library", "default", "3층 도서관 [E]")
	_add_portal(root, Vector3(0, y + 1.5, -16.5), Vector3(3, 3, 1), "stairwell_f2", "default", "계단 [E]")
	_add_light(root, Vector3(0, y + 3.0, -10), 0.7, Color(0.85, 0.82, 0.75), 10.0)
	_add_label(root, "2층 복도", Vector3(0, y + 3.0, -8))


func _build_floor1(root: Node3D) -> void:
	var y := 0.0
	_add_room(root, Vector3(14, 3.8, 14), Vector3(-14, y, 0), false, true)
	for x in [-18, -14, -10]:
		_add_box(root, Vector3(2.5, 0.75, 1), Vector3(x, y + 0.38, 2), COLORS.metal)
	_add_interact(root, Vector3(-10, y + 1, -3), Vector3(2, 2, 2), "water", "물 마시기 [E]", _on_drink_water)
	_add_interact(root, Vector3(-18, y + 1, 2), Vector3(2, 2, 2), "usb_backup", "친구 USB [E]", _on_usb_backup)
	_add_portal(root, Vector3(-14, y + 1.5, 6.5), Vector3(4, 3, 1), "stairwell_f1", "default", "계단 [E]")
	_add_light(root, Vector3(-14, y + 3.0, 0), 1.0, Color(1.0, 0.9, 0.7), 12.0)
	_add_label(root, "1층 급식실", Vector3(-14, y + 3.0, -4))

	_add_room(root, Vector3(12, 3.8, 10), Vector3(14, y, 0), false, false)
	_add_portal(root, Vector3(14, y + 1.5, 4.5), Vector3(3, 3, 1), "stairwell_f1", "lobby", "계단 [E]")
	_add_light(root, Vector3(14, y + 2.8, 0), 0.35, Color(0.6, 0.55, 0.5), 6.0, true)
	_add_label(root, "1층 현관 (어두움)", Vector3(14, y + 3.0, -2))


func _build_floor3(root: Node3D) -> void:
	var y := FLOOR_H * 2
	_add_room(root, Vector3(14, 3.8, 14), Vector3(-14, y, 0), false, true)
	for i in 4:
		_add_box(root, Vector3(1.4, 0.75, 0.9), Vector3(-17 + i * 3, y + 0.38, -2), COLORS.metal)
		_add_box(root, Vector3(0.7, 0.55, 0.08), Vector3(-17 + i * 3, y + 0.95, -2.35), COLORS.screen)
	_add_interact(root, Vector3(-14, y + 1, 3), Vector3(2, 2, 2), "cached_ppt", "캐시 PPT [E]", _on_cached_ppt)
	_add_portal(root, Vector3(-8, y + 1.5, 0), Vector3(1.2, 3, 3), "floor2_hallway", "from_lab", "2층 복도 [E]")
	_add_portal(root, Vector3(-14, y + 1.5, 6.5), Vector3(4, 3, 1), "stairwell_f3", "default", "계단 [E]")
	_add_light(root, Vector3(-14, y + 3.0, 0), 0.8, Color(0.7, 0.8, 1.0), 10.0)
	_add_label(root, "3층 컴퓨터실", Vector3(-14, y + 3.0, -4))

	_add_room(root, Vector3(14, 3.8, 14), Vector3(14, y, 0), false, true)
	for i in 5:
		_add_box(root, Vector3(0.35, 1.8, 3.5), Vector3(10 + i * 1.4, y + 0.9, 0), COLORS.wood)
	_add_interact(root, Vector3(17, y + 1, 3), Vector3(2, 2, 2), "printed_notes", "인쇄본 [E]", _on_printed_notes)
	_add_portal(root, Vector3(8, y + 1.5, 0), Vector3(1.2, 3, 3), "floor2_hallway", "from_lib", "2층 복도 [E]")
	_add_light(root, Vector3(14, y + 3.0, 0), 0.7, Color(0.9, 0.85, 0.7), 10.0)
	_add_label(root, "3층 도서관", Vector3(14, y + 3.0, -4))


func _build_floor4(root: Node3D) -> void:
	var y := FLOOR_H * 3
	_add_room(root, Vector3(14, 3.8, 14), Vector3(0, y, 8), false, true)
	_add_box(root, Vector3(2.2, 0.85, 1.1), Vector3(0, y + 0.43, 10), COLORS.desk)
	_add_interact(root, Vector3(0, y + 1, 10), Vector3(2, 2, 2), "teacher_password", "교사 계정 메모 [E]", _on_teacher_password)
	_add_portal(root, Vector3(0, y + 1.5, 14.5), Vector3(3, 3, 1), "floor4_dark_hall", "default", "어두운 복도 [E]")
	_add_light(root, Vector3(0, y + 3.0, 8), 0.6, Color(0.95, 0.88, 0.75), 8.0)
	_add_label(root, "4층 교무실", Vector3(0, y + 3.0, 5))

	# Dark hallway - horror zone, minimal light
	_add_room(root, Vector3(10, 3.8, 20), Vector3(0, y, -8), true, false)
	_add_portal(root, Vector3(0, y + 1.5, 1.5), Vector3(3, 3, 1), "floor4_office", "default", "교무실 [E]")
	_add_portal(root, Vector3(0, y + 1.5, -17.5), Vector3(3, 3, 1), "stairwell_f4", "default", "계단 [E]")
	_add_portal(root, Vector3(0, y + 1.5, -8), Vector3(2, 3, 2), "floor5_storage", "default", "5층 (위) [E]")
	_add_light(root, Vector3(0, y + 3.0, -4), 0.15, Color(0.4, 0.15, 0.1), 5.0, true)
	_add_light(root, Vector3(0, y + 2.5, -14), 0.08, Color(0.3, 0.05, 0.05), 3.0, true)
	_add_label(root, "4층 어두운 복도", Vector3(0, y + 3.0, -10))


func _build_floor5(root: Node3D) -> void:
	var y := FLOOR_H * 4
	_add_room(root, Vector3(16, 3.8, 14), Vector3(-10, y, 0), true, false)
	_add_portal(root, Vector3(-2, y + 1.5, 0), Vector3(1.2, 3, 3), "floor4_dark_hall", "from_storage", "4층 복도 [E]")
	_add_light(root, Vector3(-10, y + 2.8, 0), 0.05, Color(0.2, 0.1, 0.15), 4.0, true)
	_add_label(root, "5층 폐창고 (불 꺼짐)", Vector3(-10, y + 3.0, -4))

	_add_room(root, Vector3(14, 3.8, 12), Vector3(10, y, -6), true, false)
	_add_interact(root, Vector3(10, y + 1, -10), Vector3(4, 3, 4), "flee", "학교 밖으로 도망 [E]", _on_flee_ending)
	_add_portal(root, Vector3(4, y + 1.5, -6), Vector3(1.2, 3, 3), "floor4_dark_hall", "from_roof", "4층 복도 [E]")
	_add_portal(root, Vector3(10, y + 1.5, 0), Vector3(3, 3, 1), "stairwell_f5", "default", "계단 [E]")
	_add_light(root, Vector3(10, y + 3.5, -6), 0.2, Color(0.5, 0.55, 0.7), 8.0, true)
	_add_label(root, "5층 옥상", Vector3(10, y + 3.5, -3))


func _build_stairwell(root: Node3D, floor: int) -> void:
	var y := (floor - 1) * FLOOR_H
	_add_room(root, Vector3(6, 3.8, 8), Vector3(0, y, -14), floor >= 4, floor <= 2)
	var sy := y + 1.0
	if floor < 5:
		var target := "stairwell_f%d" % (floor + 1)
		_add_portal(root, Vector3(0, sy + 0.5, -17.5), Vector3(2, 2.5, 1), target, "default", "%d층으로 [E]" % (floor + 1))
	if floor > 1:
		var target_down := "stairwell_f%d" % (floor - 1)
		_add_portal(root, Vector3(0, sy + 0.5, -10.5), Vector3(2, 2.5, 1), target_down, "default", "%d층으로 [E]" % (floor - 1))
	if floor == 1:
		_add_portal(root, Vector3(-3, sy, -14), Vector3(1.2, 3, 3), "floor1_cafeteria", "default", "급식실 [E]")
		_add_portal(root, Vector3(3, sy, -14), Vector3(1.2, 3, 3), "floor1_lobby", "default", "현관 [E]")
	if floor == 2:
		_add_portal(root, Vector3(3, sy, -14), Vector3(1.2, 3, 3), "floor2_hallway", "default", "2층 복도 [E]")
	var light_energy := 0.25 if floor >= 4 else 0.55
	_add_light(root, Vector3(0, y + 3.0, -14), light_energy, Color(0.7, 0.65, 0.55), 6.0, floor >= 4)
	_add_label(root, "%d층 계단" % floor, Vector3(0, y + 3.0, -11))


func _spawn_panicking_donghun(root: Node3D) -> void:
	var scene: PackedScene = load("res://scenes/npc/panicking_donghun.tscn")
	if scene == null:
		return
	var npc: Node3D = scene.instantiate()
	npc.position = Vector3(0, 4.0, 7.5)
	root.add_child(npc)


func _add_room(root: Node3D, size: Vector3, center: Vector3, dark: bool, lit: bool) -> void:
	var floor_c := COLORS.dark_floor if dark else COLORS.floor
	var wall_c := COLORS.dark_wall if dark else COLORS.wall
	var ceil_c := COLORS.dark_floor if dark else COLORS.ceiling
	_add_box(root, Vector3(size.x, 0.15, size.z), center + Vector3(0, -0.08, 0), floor_c)
	_add_box(root, Vector3(size.x, 0.12, size.z), center + Vector3(0, size.y - 0.06, 0), ceil_c)
	_add_box(root, Vector3(size.x, size.y, 0.15), center + Vector3(0, size.y * 0.5, -size.z * 0.5), wall_c)
	_add_box(root, Vector3(size.x, size.y, 0.15), center + Vector3(0, size.y * 0.5, size.z * 0.5), wall_c)
	_add_box(root, Vector3(0.15, size.y, size.z), center + Vector3(-size.x * 0.5, size.y * 0.5, 0), wall_c)
	_add_box(root, Vector3(0.15, size.y, size.z), center + Vector3(size.x * 0.5, size.y * 0.5, 0), wall_c)


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


func _add_light(root: Node3D, pos: Vector3, energy: float, color: Color, range: float, flicker: bool = false) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.position = pos
	light.light_energy = energy
	light.light_color = color
	light.omni_range = range
	light.shadow_enabled = true
	if flicker:
		light.set_script(FLICKER_SCRIPT)
		light.set("base_energy", energy)
		light.set("flicker_amount", 0.8 if energy < 0.3 else 0.45)
	root.add_child(light)
	return light


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
	label.font_size = 32
	label.modulate = Color(0.85, 0.75, 0.55) if "어두" in text or "폐" in text else Color(1, 0.9, 0.65)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(label)


func _make_material(color: Color) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = PS1_SHADER
	mat.set_shader_parameter("albedo_color", color)
	return mat


func _on_laptop_interact(_player: Node3D) -> void:
	if GameState.current_zone == "floor2_classroom" and GameState.can_present():
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
