extends Node

signal zone_loaded(zone: String)

const SCHOOL_SCRIPT := preload("res://scripts/levels/school_builder.gd")

var _world_root: Node3D
var _npc_root: Node3D
var _school: Node3D
var _builder: Node3D
var _school_built: bool = false


func setup(world_root: Node3D, npc_root: Node3D) -> void:
	_world_root = world_root
	_npc_root = npc_root


func build_school_if_needed() -> void:
	if _school_built:
		return
	_school = Node3D.new()
	_school.name = "School"
	_world_root.add_child(_school)
	_builder = SCHOOL_SCRIPT.new()
	_school.add_child(_builder)
	_builder.build_school(_school)
	_spawn_npcs()
	_school_built = true


func travel_to(spawn_id: String) -> Vector3:
	build_school_if_needed()
	GameState.change_zone(_zone_from_spawn(spawn_id))
	var spawn: Vector3 = _builder.get_spawn(spawn_id)
	zone_loaded.emit(spawn_id)
	return spawn


func has_spawn(spawn_id: String) -> bool:
	return _builder != null and _builder.has_spawn(spawn_id)


func _zone_from_spawn(spawn_id: String) -> String:
	if spawn_id.contains("_from_"):
		return spawn_id.split("_from_")[0]
	if spawn_id.begins_with("stairwell"):
		return spawn_id
	return spawn_id


func _spawn_npcs() -> void:
	var teacher_scene: PackedScene = load("res://scenes/npc/teacher.tscn")
	_add_npc(teacher_scene, Vector3(-2, 4, -10), "korean_teacher", "korean_teacher")
	_add_npc(teacher_scene, Vector3(-14, 8, 2), "it_teacher", "it_teacher")
	_add_npc(teacher_scene, Vector3(14, 8, 2), "librarian", "librarian")
	_add_npc(teacher_scene, Vector3(0, 12, 6), "principal", "principal")
	_add_npc(teacher_scene, Vector3(0, 12, -12), "hall_monitor", "korean_teacher")
	_add_npc(teacher_scene, Vector3(-10, 16, 2), "storage_ghost", "principal")


func _add_npc(scene: PackedScene, pos: Vector3, npc_id: String, role: String) -> void:
	if scene == null:
		return
	var npc: Node3D = scene.instantiate()
	npc.position = pos
	if npc.has_method("setup"):
		npc.setup(npc_id, role)
	_npc_root.add_child(npc)
