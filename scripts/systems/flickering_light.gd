extends OmniLight3D

@export var base_energy: float = 1.0
@export var flicker_amount: float = 0.6
@export var speed: float = 8.0

var _time: float = 0.0


func _ready() -> void:
	if base_energy <= 0.0:
		base_energy = light_energy


func _process(delta: float) -> void:
	_time += delta * speed
	var noise := sin(_time) * sin(_time * 2.7) * sin(_time * 0.4)
	light_energy = maxf(0.02, base_energy + noise * flicker_amount * base_energy)
	if randf() < delta * 0.08:
		light_energy = maxf(0.01, base_energy * 0.05)
