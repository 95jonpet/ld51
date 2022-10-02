class_name Portal
extends CharacterBody2D

signal portal_reached(player: Player)


const TARGET_FPS := 60
const GRAVITY := 4
const MAX_SPEED := 64


func _physics_process(delta: float) -> void:
	if is_on_floor():
		return
	velocity.y += GRAVITY * delta * TARGET_FPS
	velocity.y = clamp(velocity.y, -MAX_SPEED * 5, MAX_SPEED * 5)
	move_and_slide()


func _on_area_body_entered(body: Node2D) -> void:
	if body is Player:
		portal_reached.emit(body as Player)
