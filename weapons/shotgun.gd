extends Weapon

const BULLET_SPEED := 256

const BULLLET_SCENE := preload("res://player/bullet.tscn")

@onready var barrel: Marker2D = $Barrel


func _shoot(direction: float) -> void:
	var offset := PI / 15
	_shoot_in_direction(direction - offset)
	_shoot_in_direction(direction)
	_shoot_in_direction(direction + offset)


func _shake_intensity() -> float:
	return 32.0


func _sound() -> AudioStream:
	return preload("res://weapons/shotgun.wav")


func _shoot_in_direction(direction: float) -> void:
	var bullet := BULLLET_SCENE.instantiate()
	bullet.global_position = barrel.global_position
	bullet.rotation = direction
	bullet.velocity = Vector2(BULLET_SPEED, 0).rotated(direction)
	get_tree().root.add_child(bullet)
