extends CharacterBody3D

const WALK_SPEED := 2.5
const CHASE_SPEED := 4.5
const DETECT_RANGE := 8.0
const LOSE_RANGE := 14.0

@export var patrol_points: Array[Vector3] = []
@export var npc_role: String = "teacher"

var _patrol_index: int = 0
var _chasing: bool = false
var _player: Node3D = null
var _sprite: Sprite3D
var _wait_timer: float = 0.0


func setup(npc_id: String, role: String) -> void:
	name = npc_id
	npc_role = role
	if patrol_points.is_empty():
		patrol_points = [global_position, global_position + Vector3(3, 0, 0), global_position + Vector3(-3, 0, 2)]


func _ready() -> void:
	add_to_group("npc")
	collision_layer = 4
	collision_mask = 1
	_player = get_tree().get_first_node_in_group("player")
	_build_visual()


func _build_visual() -> void:
	var body := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.6, 1.2, 0.4)
	body.mesh = mesh
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://shaders/ps1_snap.gdshader")
	match npc_role:
		"korean_teacher":
			mat.set_shader_parameter("albedo_color", Color(0.8, 0.2, 0.2))
		"it_teacher":
			mat.set_shader_parameter("albedo_color", Color(0.2, 0.4, 0.8))
		"principal":
			mat.set_shader_parameter("albedo_color", Color(0.15, 0.15, 0.2))
		"librarian":
			mat.set_shader_parameter("albedo_color", Color(0.5, 0.3, 0.6))
		_:
			mat.set_shader_parameter("albedo_color", Color(0.7, 0.5, 0.3))
	body.material_override = mat
	body.position = Vector3(0, 0.6, 0)
	add_child(body)

	_sprite = Sprite3D.new()
	_sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	_sprite.pixel_size = 0.004
	_sprite.position = Vector3(0, 1.6, 0)
	var tex := load("res://assets/characters/donghun_face.png")
	if npc_role != "classmate" and npc_role != "friend" and npc_role != "runner":
		_sprite.texture = _make_teacher_face()
	else:
		_sprite.texture = tex
	add_child(_sprite)

	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.8
	col.shape = shape
	add_child(col)


func _make_teacher_face() -> ImageTexture:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.9, 0.75, 0.6))
	for i in 64:
		img.set_pixel(20, 24 + i % 3, Color.BLACK)
		img.set_pixel(44, 24 + i % 3, Color.BLACK)
	for x in range(22, 42):
		img.set_pixel(x, 40, Color(0.8, 0.2, 0.2))
	var tex := ImageTexture.create_from_image(img)
	return tex


func _physics_process(delta: float) -> void:
	if GameState.has_flag("ending_triggered"):
		return
	if _player == null:
		_player = get_tree().get_first_node_in_group("player")
		return

	var dist := global_position.distance_to(_player.global_position)
	if _chasing:
		if dist > LOSE_RANGE:
			_chasing = false
		else:
			_move_toward(_player.global_position, CHASE_SPEED, delta)
			PanicManager.add_panic(0.8 * delta, "%s에게 들켰다!" % _get_role_name())
			return
	elif dist < DETECT_RANGE and _can_see_player():
		var spotted := PanicManager.running
		if npc_role == "principal" and GameState.has_item("teacher_password"):
			spotted = true
		if spotted:
			_chasing = true
			get_tree().call_group("game_root", "show_message", "%s: \"거기 서!\"" % _get_role_name(), 2.0)
			PanicManager.add_panic(5.0, "선생님에게 들킴!")

	if _wait_timer > 0:
		_wait_timer -= delta
		return

	if patrol_points.size() > 0:
		var target: Vector3 = patrol_points[_patrol_index]
		if global_position.distance_to(target) < 0.5:
			_patrol_index = (_patrol_index + 1) % patrol_points.size()
			_wait_timer = 1.5
		else:
			_move_toward(target, WALK_SPEED, delta)


func _move_toward(target: Vector3, speed: float, delta: float) -> void:
	var dir := (target - global_position)
	dir.y = 0
	if dir.length() < 0.05:
		return
	dir = dir.normalized()
	velocity = dir * speed
	move_and_slide()
	look_at(global_position + dir, Vector3.UP)


func _can_see_player() -> bool:
	if _player == null:
		return false
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(global_position + Vector3(0, 1.5, 0), _player.global_position + Vector3(0, 1, 0))
	query.exclude = [self]
	var result := space.intersect_ray(query)
	return result.is_empty() or result.collider == _player


func _get_role_name() -> String:
	match npc_role:
		"korean_teacher":
			return "국어 선생님"
		"it_teacher":
			return "컴퓨터실 선생님"
		"principal":
			return "교장 선생님"
		"librarian":
			return "사서"
		_:
			return "선생님"
