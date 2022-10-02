class_name Weapon
extends Node2D

var _can_shoot: bool = true
@onready var _timer: Timer = $Timer


func shoot(direction: float) -> void:
	if not _can_shoot:
		return

	_can_shoot = false
	AudioPlayer.play(_sound())
	ScreenShake.apply_shake(_shake_intensity())
	_shoot(direction)
	_timer.start()


func _shake_intensity() -> float:
	return 16.0


func _shoot(_direction: float) -> void:
	pass


func _sound() -> AudioStream:
	return AudioStream.new()


func _on_timer_timeout() -> void:
	_can_shoot = true
