extends CharacterBody2D

const TARGET_FPS := 60
const ACCELERATION := 8
const MAX_SPEED := 64
const FRICTION := 10
const AIR_RESISTANCE := 1
const GRAVITY := 4
const JUMP_FORCE := 140
const BULLET_SPEED := 256

const BULLLET_SCENE := preload("res://player/bullet.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bullet_marker: Marker2D = $BulletMarker
@onready var shoot_timer: Timer = $ShootTimer
@onready var sprite: Sprite2D = $Sprite
var can_shoot: bool = true


func _shoot() -> void:
	if not can_shoot:
		return
	var bullet := BULLLET_SCENE.instantiate()
	bullet.global_position = bullet_marker.global_position
	bullet.velocity = get_local_mouse_position().normalized() * BULLET_SPEED
	add_sibling(bullet)
	bullet.look_at(get_global_mouse_position())
	can_shoot = false
	shoot_timer.start()


func _physics_process(delta: float) -> void:
	var x_input := Input.get_axis("action_left", "action_right")

	if x_input != 0:
		animation_player.play("Run")
		velocity.x += x_input * ACCELERATION * delta * TARGET_FPS
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
		sprite.flip_h = x_input < 0
	else:
		animation_player.play("Stand")

	velocity.y += GRAVITY * delta * TARGET_FPS

	if is_on_floor():
		if x_input == 0:
			velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)

		if Input.is_action_just_pressed("action_jump"):
			velocity.y = -JUMP_FORCE
	else:
		animation_player.play("Jump")

		if Input.is_action_just_released("action_jump") and velocity.y < -JUMP_FORCE / 2.0:
			velocity.y = -JUMP_FORCE / 2.0
		if x_input == 0:
			velocity.x = lerp(velocity.x, 0.0, AIR_RESISTANCE * delta)

	move_and_slide()

	if Input.is_action_pressed("action_shoot"):
		_shoot()


func _on_shoot_timer_timeout() -> void:
	can_shoot = true
