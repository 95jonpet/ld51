extends CharacterBody2D


func hurt() -> void:
	queue_free()


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("hurt"):
			collider.call("hurt")
		queue_free()


func _on_death_timer_timeout() -> void:
	queue_free()
