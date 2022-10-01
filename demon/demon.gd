extends CharacterBody2D

const MOVEMENT_SPEED := 48
const GRAVITY := 4
const TARGET_FPS := 60
var direction := Vector2.RIGHT

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ledge_check: RayCast2D = $LedgeCheck
@onready var sprite: Sprite2D = $Sprite
@onready var particles: CPUParticles2D = $Particles
@onready var player_detector: RayCast2D = $PlayerDetector


func hurt() -> void:
	queue_free()


func _ready() -> void:
	animation_player.play("Run")


func _physics_process(delta: float) -> void:
	var is_detecting_player := player_detector.is_colliding()
	particles.emitting = is_detecting_player

	if not is_on_floor():
		animation_player.play("Jump")
		velocity.y += GRAVITY * delta * TARGET_FPS
		velocity.x = 0
	else:
		animation_player.play("Run")

		# Change direction if colliding with a wall or approaching a ledge.
		if is_on_wall() or not ledge_check.is_colliding():
			direction.x *= -1
			sprite.flip_h = direction.x < 0
			ledge_check.position.x *= -1
			player_detector.target_position.x *= -1

		velocity.x = direction.x * MOVEMENT_SPEED
	move_and_slide()
