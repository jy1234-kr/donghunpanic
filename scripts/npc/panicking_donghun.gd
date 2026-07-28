extends Node3D

const FACE_TEX := preload("res://assets/characters/donghun_face.png")

var _sprite: Sprite3D
var _time: float = 0.0
var _base_y: float = 0.0


func _ready() -> void:
	add_to_group("panicking_donghun")
	_base_y = position.y
	_build_body()
	_build_face()


func _build_body() -> void:
	var body := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.55, 1.1, 0.35)
	body.mesh = mesh
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://shaders/ps1_snap.gdshader")
	mat.set_shader_parameter("albedo_color", Color(0.12, 0.12, 0.18))
	body.material_override = mat
	body.position = Vector3(0, 0.55, 0)
	add_child(body)


func _build_face() -> void:
	_sprite = Sprite3D.new()
	_sprite.texture = FACE_TEX
	_sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	_sprite.pixel_size = 0.0055
	_sprite.position = Vector3(0, 1.45, 0)
	add_child(_sprite)


func _process(delta: float) -> void:
	_time += delta
	var shake := sin(_time * 14.0) * 0.04 + sin(_time * 23.0) * 0.02
	position.x = shake
	position.y = _base_y + absf(sin(_time * 10.0)) * 0.06
	rotation.z = sin(_time * 12.0) * 0.08
	if _sprite:
		_sprite.modulate = Color(1.0, 0.85 + sin(_time * 6.0) * 0.1, 0.85 + sin(_time * 6.0) * 0.1)
		_sprite.scale = Vector3.ONE * (1.0 + sin(_time * 8.0) * 0.04)


func get_focus_position() -> Vector3:
	return global_position + Vector3(0, 1.4, 0)
