extends Node3D

var _player: Node3D = null
var _panic_timer: float = 0.0


func setup(npc_id: String, _role: String = "") -> void:
	name = npc_id
	_build_visual()


func _ready() -> void:
	add_to_group("npc")
	add_to_group("classmate")
	_player = get_tree().get_first_node_in_group("player")


func _build_visual() -> void:
	var body := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.5, 1.0, 0.35)
	body.mesh = mesh
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://shaders/ps1_snap.gdshader")
	mat.set_shader_parameter("albedo_color", Color(0.3, 0.5, 0.8))
	body.material_override = mat
	body.position = Vector3(0, 0.5, 0)
	add_child(body)

	var sprite := Sprite3D.new()
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sprite.pixel_size = 0.0035
	sprite.position = Vector3(0, 1.3, 0)
	sprite.texture = load("res://assets/characters/donghun_face.png")
	add_child(sprite)


func _process(delta: float) -> void:
	if GameState.has_flag("ending_triggered"):
		return
	if _player == null:
		return
	if GameState.current_zone != "classroom":
		return
	var dist := global_position.distance_to(_player.global_position)
	if dist < 5.0:
		look_at(Vector3(_player.global_position.x, global_position.y, _player.global_position.z), Vector3.UP)
		_panic_timer += delta
		if _panic_timer > 2.0:
			_panic_timer = 0.0
			if GameState.has_flag("login_failed"):
				PanicManager.add_panic(2.0, "동급생들이 쳐다본다...")
