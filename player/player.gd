class_name Player
extends CharacterBody2D

enum State { MOVE, CLIMB }

const TARGET_FPS := 60
const ACCELERATION := 8
const MAX_SPEED := 64
const FRICTION := 10
const AIR_RESISTANCE := 1
const GRAVITY := 4
const JUMP_FORCE := 140

const JUMP_SOUND := preload("res://player/jump.wav")

var state: State = State.MOVE
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bullet_marker: Marker2D = $BulletMarker
@onready var hand: Marker2D = $Hand
@onready var ladder_check: RayCast2D = $LadderCheck
@onready var sprite: Sprite2D = $Sprite


func hurt() -> void:
	print_debug("TODO: Hurt the player")


func set_weapon(weapon_resource: Resource) -> void:
	var weapon: Weapon = weapon_resource.instantiate()
	for child in hand.get_children():
		child.queue_free()
	hand.add_child(weapon)


func is_on_ladder() -> bool:
	return ladder_check.is_colliding()


func _move_state(input: Vector2, delta: float):
	if is_on_ladder() and input.y != 0:
		state = State.CLIMB

	_apply_gravity(delta)

	if input.x != 0:
		animation_player.play("Run")
		velocity.x += input.x * ACCELERATION * delta * TARGET_FPS
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	else:
		animation_player.play("Stand")

	if is_on_floor():
		if input.x == 0:
			velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)

		# Trigger jump.
		if Input.is_action_just_pressed("action_jump"):
			AudioPlayer.play(JUMP_SOUND)
			velocity.y = -JUMP_FORCE
	else:
		animation_player.play("Jump")

		# Jump higher if the jump action is sustained.
		if Input.is_action_just_released("action_jump") and velocity.y < -JUMP_FORCE / 2.0:
			velocity.y = -JUMP_FORCE / 2.0
		if input.x == 0:
			velocity.x = lerp(velocity.x, 0.0, AIR_RESISTANCE * delta)


func _climb_state(input: Vector2, _delta: float):
	if not is_on_ladder():
		state = State.MOVE
	if input.length() != 0:
		animation_player.play("Run")
	else:
		animation_player.play("Stand")
	velocity = input * MAX_SPEED


func _shoot() -> void:
	var weapon: Weapon = hand.get_child(0)
	weapon.shoot(global_position.angle_to_point(get_global_mouse_position()))


func _apply_gravity(delta: float) -> void:
	velocity.y += GRAVITY * delta * TARGET_FPS
	velocity.y = clamp(velocity.y, -MAX_SPEED * 5, MAX_SPEED * 5)


func _physics_process(delta: float) -> void:
	var input := Input.get_vector("action_left", "action_right", "action_up", "action_down")
	match state:
		State.CLIMB: _climb_state(input, delta)
		State.MOVE: _move_state(input, delta)
	move_and_slide()

	# Update the player's direction.
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
