extends Node

@export var shake_decay_rate: float = 5.0
@export var noise_shake_speed: float = 30.0

@onready var noise: Noise = FastNoiseLite.new()

var noise_index: float = 0.0
var shake_strength: float = 0.0


func apply_shake(strength: float) -> void:
	shake_strength = strength


func get_noise_offset(delta: float) -> Vector2:
	noise_index += delta * noise_shake_speed
	return Vector2(
		noise.get_noise_2d(1, noise_index) * shake_strength,
		noise.get_noise_2d(100, noise_index) * shake_strength,
	)


func _process(delta: float) -> void:
	shake_strength = lerp(shake_strength, 0.0, shake_decay_rate * delta)
