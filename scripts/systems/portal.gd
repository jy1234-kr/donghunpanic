class_name Portal
extends Area3D

@export var target_zone: String = "hallway"
@export var target_spawn: String = "default"
@export var prompt_text: String = "이동 [E]"
@export var requires_flag: String = ""
@export var blocked_message: String = "아직 나갈 수 없습니다."

signal portal_used

var _player_inside: Node3D = null


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("register_interactable"):
		_player_inside = body
		body.register_interactable(self)


func _on_body_exited(body: Node3D) -> void:
	if body.has_method("unregister_interactable"):
		body.unregister_interactable(self)
	if _player_inside == body:
		_player_inside = null


func can_interact() -> bool:
	if requires_flag != "" and not GameState.has_flag(requires_flag):
		return false
	return true


func interact(_player: Node3D) -> void:
	if not can_interact():
		if _player_inside and _player_inside.has_method("show_message"):
			_player_inside.show_message(blocked_message)
		return
	portal_used.emit()
	get_tree().call_group("game_root", "travel_to_zone", target_zone, target_spawn)


func get_prompt() -> String:
	if not can_interact():
		return blocked_message
	return prompt_text
