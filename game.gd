extends Node2D

@onready var timer: Timer = $Timer
@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var player: Player = $Player
@onready var world: World = $World

const WEAPONS: Array[Resource] = [
	preload("res://weapons/gun.tscn"),
	preload("res://weapons/machine_gun.tscn"),
	preload("res://weapons/shotgun.tscn"),
]


func randomize_weapon() -> void:
	var weapon := WEAPONS[randi() % len(WEAPONS)]
	player.set_weapon(weapon)


func randomize_world() -> void:
	var spawn := world.generate_random_world()
	player.global_position = spawn


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.html("#130208"))
	randomize_world()


func _process(_delta: float) -> void:
	timer_label.text = str(timer.time_left).pad_zeros(2).pad_decimals(2)


func _on_timer_timeout() -> void:
	randomize_weapon()
