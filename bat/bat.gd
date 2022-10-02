extends CharacterBody2D

const MOVEMENT_SPEED := 48
const MIN_DISTANCE_SQUARED := 8 * 8
const HURT_SOUND := preload("res://demon/demon_hurt.wav")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var target_position := global_position
@onready var left_world_check: RayCast2D = $LeftWorldCheck
@onready var right_world_check: RayCast2D = $RightWorldCheck
@onready var up_world_check: RayCast2D = $UpWorldCheck
@onready var down_world_check: RayCast2D = $DownWorldCheck

@onready var world_checks: Array[RayCast2D] = [
	left_world_check,
	right_world_check,
	up_world_check,
	down_world_check,
]

func hurt() -> void:
	AudioPlayer.play(HURT_SOUND)
	queue_free()


func reset_target() -> void:
	var world_check := world_checks[randi() % len(world_checks)]
	world_check.force_raycast_update()
	var collision_point = world_check.get_collision_point()
	var offset = (collision_point - global_position).normalized() * (Section.GRID_SIZE / 2.0)
	target_position = collision_point - offset


func _ready() -> void:
	animation_player.play("Fly")
	reset_target()


func _physics_process(delta: float) -> void:
	if global_position.distance_squared_to(target_position) <= MIN_DISTANCE_SQUARED:
		reset_target()
	global_position += (target_position - global_position).normalized() * MOVEMENT_SPEED * delta
