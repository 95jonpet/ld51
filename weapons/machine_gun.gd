extends Weapon

const BULLET_SPEED := 256

const BULLLET_SCENE := preload("res://player/bullet.tscn")

@onready var barrel: Marker2D = $Barrel


func _shoot(direction: float) -> void:
	var bullet := BULLLET_SCENE.instantiate()
	direction += randf_range(-PI / 12, PI / 12)
	bullet.global_position = barrel.global_position
	get_tree().root.add_child(bullet)
	bullet.rotation = direction
	bullet.velocity = Vector2(BULLET_SPEED, 0).rotated(direction)


func _sound() -> AudioStream:
	return preload("res://weapons/machine_gun.wav")

