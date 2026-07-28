extends Control

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var viewport_container: SubViewportContainer = $SubViewportContainer
@onready var world_root: Node3D = $SubViewportContainer/SubViewport/WorldRoot
@onready var npc_root: Node3D = $SubViewportContainer/SubViewport/NPCRoot
@onready var player: CharacterBody3D = $SubViewportContainer/SubViewport/Player
@onready var cutscene_camera: Camera3D = $SubViewportContainer/SubViewport/CutsceneCamera
@onready var hud: Control = $UI/HUD
@onready var google_login: Control = $UI/GoogleLogin
@onready var dialogue_box: Control = $UI/DialogueBox
@onready var pause_menu: Control = $UI/PauseMenu
@onready var ending_screen: Control = $UI/EndingScreen
@onready var panic_intro: Control = $UI/PanicIntro

var _zone_manager: Node


func _ready() -> void:
	add_to_group("game_root")
	sub_viewport.handle_input_locally = true
	sub_viewport.gui_disable_input = false
	_zone_manager = load("res://scripts/levels/zone_manager.gd").new()
	add_child(_zone_manager)
	_zone_manager.setup(world_root, npc_root)

	google_login.login_completed.connect(_on_login_completed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	pause_menu.quit_to_menu.connect(_on_quit_to_menu)
	ending_screen.restart_requested.connect(_restart_game)
	ending_screen.menu_requested.connect(_on_quit_to_menu)
	GameState.ending_triggered.connect(_on_ending_triggered)

	_start_game()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if viewport_container.get_global_rect().has_point(event.position):
			sub_viewport.push_input(event)
			if not player.is_controls_locked():
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if viewport_container.get_global_rect().has_point(event.position):
			sub_viewport.push_input(event)


func _start_game() -> void:
	player.set_controls_locked(true)
	if not SaveManager.pending_load:
		GameState.reset_game()
	else:
		SaveManager.pending_load = false

	_zone_manager.build_school_if_needed()
	_travel_to(GameState.current_zone)
	await panic_intro.play()
	await _play_opening_cutscene()
	player.unlock_from_ui()
	AudioManager.play_bell()
	await get_tree().create_timer(0.5).timeout
	show_dialogue("prologue_start")
	GameState.start_prologue()


func _play_opening_cutscene() -> void:
	var donghun: Node3D = get_tree().get_first_node_in_group("panicking_donghun")
	if donghun == null:
		return
	player.camera.current = false
	cutscene_camera.current = true
	var look_pos: Vector3 = donghun.get_focus_position() if donghun.has_method("get_focus_position") else donghun.global_position + Vector3(0, 1.4, 0)
	cutscene_camera.global_position = look_pos + Vector3(0.8, 0.3, 1.6)
	cutscene_camera.look_at(look_pos, Vector3.UP)
	player.add_camera_shake(0.08)
	PanicManager.add_panic(8.0, "발표 시작...")
	for i in 4:
		player.add_camera_shake(0.04)
		AudioManager.play_panic_pulse()
		await get_tree().create_timer(0.35).timeout
	await get_tree().create_timer(0.8).timeout
	cutscene_camera.current = false
	player.camera.current = true


func _travel_to(spawn_id: String) -> void:
	var spawn: Vector3 = _zone_manager.travel_to(spawn_id)
	player.teleport_to(spawn)
	hud.refresh_zone()
	_update_horror_mood()


func travel_to_zone(zone: String, spawn: String = "default") -> void:
	if zone == "floor2_classroom" and GameState.can_present() and GameState.current_zone != "floor2_classroom":
		GameState.set_chapter(5)
	var spawn_id := zone
	if spawn != "default":
		var variant := "%s_%s" % [zone, spawn]
		if _zone_manager.has_spawn(variant):
			spawn_id = variant
	_travel_to(spawn_id)


func _update_horror_mood() -> void:
	if GameState.is_dark_zone():
		hud.show_message("불이 꺼져 있다... 손전등이 켜졌다.", 2.0)
		AudioManager.play_panic_pulse()


func open_google_login() -> void:
	player.lock_for_ui()
	google_login.open_login()


func _on_login_completed(success: bool) -> void:
	player.unlock_from_ui()
	if success:
		return
	GameState.on_login_failed()
	player.add_camera_shake(0.15)
	show_dialogue("login_fail")


func show_dialogue(key: String) -> void:
	player.lock_for_ui()
	dialogue_box.show_dialogue(key)


func _on_dialogue_finished() -> void:
	player.unlock_from_ui()


func show_message(text: String, duration: float = 3.0) -> void:
	hud.show_message(text, duration)


func toggle_pause() -> void:
	if ending_screen.visible or google_login.visible or dialogue_box.visible or panic_intro.visible:
		return
	pause_menu.toggle()
	player.set_controls_locked(pause_menu.visible)


func start_final_presentation() -> void:
	player.lock_for_ui()
	if GameState.inventory.size() >= 3:
		GameState.trigger_ending("hidden")
	elif GameState.has_item("printed_notes") or PanicManager.level > 60:
		show_dialogue("final_improv")
		await dialogue_box.dialogue_finished
		GameState.trigger_ending("improv")
	else:
		show_dialogue("final_perfect")
		await dialogue_box.dialogue_finished
		GameState.trigger_ending("perfect")


func _on_ending_triggered(ending_id: String) -> void:
	player.set_controls_locked(true)
	ending_screen.show_ending(ending_id)


func _restart_game() -> void:
	get_tree().reload_current_scene()


func _on_quit_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
