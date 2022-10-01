class_name Player
extends CharacterBody2D

const TARGET_FPS := 60
const ACCELERATION := 8
const MAX_SPEED := 64
const FRICTION := 10
const AIR_RESISTANCE := 1
const GRAVITY := 4
const JUMP_FORCE := 140

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bullet_marker: Marker2D = $BulletMarker
@onready var hand: Marker2D = $Hand
@onready var sprite: Sprite2D = $Sprite


func hurt() -> void:
	print_debug("TODO: Hurt the player")


func set_weapon(weapon_resource: Resource) -> void:
	var weapon: Weapon = weapon_resource.instantiate()
	for child in hand.get_children():
		child.queue_free()
	hand.add_child(weapon)


func _shoot() -> void:
	var weapon: Weapon = hand.get_child(0)
	weapon.shoot(global_position.angle_to_point(get_global_mouse_position()))


func _physics_process(delta: float) -> void:
	var x_input := Input.get_axis("action_left", "action_right")

	if x_input != 0:
		animation_player.play("Run")
		velocity.x += x_input * ACCELERATION * delta * TARGET_FPS
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
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

	var mouse_position := get_global_mouse_position()
	hand.look_at(mouse_position)
	if global_position.x < mouse_position.x:
		hand.scale.y = 1
		hand.position.x = abs(hand.position.x)
		sprite.flip_h = false
	else:
		hand.scale.y = -1
		hand.position.x = -abs(hand.position.x)
		sprite.flip_h = true

	if Input.is_action_pressed("action_shoot"):
		_shoot()
