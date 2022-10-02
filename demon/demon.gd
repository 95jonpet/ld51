extends CharacterBody2D

const MOVEMENT_SPEED := 48
const GRAVITY := 4
const TARGET_FPS := 60
const HURT_SOUND := preload("res://demon/demon_hurt.wav")
const SHOOT_SOUND := preload("res://demon/demon_shoot.wav")
const BULLET_SCENE := preload("res://demon/demon_bullet.tscn")
const BULLET_SPEED := 128
var direction := Vector2.RIGHT
var target: Node2D = null

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bullet_marker: Marker2D = $BulletMarker
@onready var ledge_check: RayCast2D = $LedgeCheck
@onready var sprite: Sprite2D = $Sprite
@onready var particles: CPUParticles2D = $Particles
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var shoot_timer: Timer = $ShootTimer


func hurt() -> void:
	AudioPlayer.play(HURT_SOUND)
	Statistics.increment_enemies_killed()
	queue_free()


func shoot() -> void:
	if not target:
		return
	
	# Don't shoot unless the player is in the line of sight.
	player_detector.target_position = player_detector.to_local(target.global_position)
	player_detector.force_raycast_update()
	if player_detector.is_colliding():
		var collider := player_detector.get_collider()
		if not collider is Player:
			return

	AudioPlayer.play(SHOOT_SOUND)
	var target_position := target.global_position + Vector2(0, -8)
	var bullet := BULLET_SCENE.instantiate()
	add_sibling(bullet)
	bullet.global_position = bullet_marker.global_position
	bullet.rotation = bullet.global_position.angle_to_point(target_position)
	bullet.velocity = bullet.global_position.direction_to(target_position) * BULLET_SPEED


func _ready() -> void:
	animation_player.play("Run")


func _physics_process(delta: float) -> void:
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


func _on_player_detection_area_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	target = body
	particles.emitting = true
	shoot_timer.start()


func _on_player_detection_area_body_exited(body: Node2D) -> void:
	if not body is Player:
		return
	particles.emitting = false
	shoot_timer.stop()


func _on_shoot_timer_timeout() -> void:
	shoot()
