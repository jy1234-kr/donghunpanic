extends CharacterBody3D

const WALK_SPEED := 4.0
const RUN_SPEED := 6.5
const BOB_FREQ := 9.0
const BOB_AMP := 0.035
const HEAD_HEIGHT := 0.62

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var flashlight: SpotLight3D = $Head/Camera3D/Flashlight
@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _interactables: Array = []
var _current_interactable = null
var _bob_time: float = 0.0
var _controls_locked: bool = false
var _look_pitch: float = 0.0
var _mouse_delta: Vector2 = Vector2.ZERO
var _shake_strength: float = 0.0


func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	camera.current = true
	head.position.y = HEAD_HEIGHT
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	interact_ray.add_exception(self)
	_update_flashlight()


func _input(event: InputEvent) -> void:
	if _controls_locked:
		return
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_mouse_delta += event.relative
	if event.is_action_pressed("interact"):
		_try_interact()
	if event.is_action_pressed("pause"):
		get_tree().call_group("game_root", "toggle_pause")


func _physics_process(delta: float) -> void:
	_apply_look(delta)
	_update_flashlight()

	if _controls_locked:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var running := Input.is_action_pressed("sprint") and direction.length() > 0.01
	PanicManager.set_running(running)
	var speed := RUN_SPEED if running else WALK_SPEED

	if direction.length() > 0.01:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		_bob_time += delta * (BOB_FREQ * (1.4 if running else 1.0))
		head.position.y = HEAD_HEIGHT + sin(_bob_time) * BOB_AMP
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		head.position.y = move_toward(head.position.y, HEAD_HEIGHT, delta * 3.0)

	move_and_slide()
	_apply_shake(delta)
	_update_interactable()


func _apply_look(_delta: float) -> void:
	if _mouse_delta.length() < 0.001:
		return
	var sens := SaveManager.mouse_sensitivity
	rotate_y(-_mouse_delta.x * sens)
	_look_pitch = clampf(_look_pitch - _mouse_delta.y * sens, deg_to_rad(-85), deg_to_rad(85))
	head.rotation.x = _look_pitch
	_mouse_delta = Vector2.ZERO


func _apply_shake(delta: float) -> void:
	if _shake_strength <= 0.0:
		return
	camera.hoffset = sin(Time.get_ticks_msec() * 0.04) * _shake_strength
	camera.voffset = cos(Time.get_ticks_msec() * 0.035) * _shake_strength
	_shake_strength = move_toward(_shake_strength, 0.0, delta * 0.8)


func add_camera_shake(amount: float) -> void:
	_shake_strength = clampf(_shake_strength + amount, 0.0, 0.12)


func _update_flashlight() -> void:
	if flashlight == null:
		return
	var dark := GameState.is_dark_zone()
	flashlight.visible = dark
	flashlight.light_energy = 2.2 if dark else 0.0


func register_interactable(obj) -> void:
	if obj not in _interactables:
		_interactables.append(obj)
		_update_interactable()


func unregister_interactable(obj) -> void:
	_interactables.erase(obj)
	if _current_interactable == obj:
		_current_interactable = null
		_update_interactable()


func _update_interactable() -> void:
	var best = null
	var best_dist := 999.0
	for obj in _interactables:
		if obj == null or not is_instance_valid(obj):
			continue
		if obj.has_method("can_interact") and not obj.can_interact():
			continue
		var dist := global_position.distance_to(obj.global_position)
		if dist < best_dist and dist < 3.5:
			best_dist = dist
			best = obj
	_current_interactable = best
	if best:
		get_tree().call_group("hud", "set_prompt", best.get_prompt() if best.has_method("get_prompt") else "조사 [E]")
	else:
		get_tree().call_group("hud", "set_prompt", "")


func _try_interact() -> void:
	if _current_interactable and _current_interactable.has_method("interact"):
		AudioManager.play_ui_click()
		_current_interactable.interact(self)


func is_controls_locked() -> bool:
	return _controls_locked


func set_controls_locked(locked: bool) -> void:
	_controls_locked = locked
	if locked:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_mouse_delta = Vector2.ZERO


func teleport_to(pos: Vector3) -> void:
	global_position = pos
	velocity = Vector3.ZERO


func show_message(text: String, duration: float = 3.0) -> void:
	get_tree().call_group("hud", "show_message", text, duration)


func lock_for_ui() -> void:
	set_controls_locked(true)


func unlock_from_ui() -> void:
	set_controls_locked(false)
