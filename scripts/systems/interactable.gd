class_name Interactable
extends Area3D

signal interacted(player: Node3D)

@export var prompt_text: String = "조사하기 [E]"
@export var one_shot: bool = false
@export var interaction_id: String = ""

var _used: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	collision_layer = 0
	collision_mask = 2


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("register_interactable"):
		body.register_interactable(self)


func _on_body_exited(body: Node3D) -> void:
	if body.has_method("unregister_interactable"):
		body.unregister_interactable(self)


func can_interact() -> bool:
	return not one_shot or not _used


func interact(player: Node3D) -> void:
	if not can_interact():
		return
	interacted.emit(player)
	if one_shot:
		_used = true


func get_prompt() -> String:
	return prompt_text
