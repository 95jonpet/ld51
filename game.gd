extends Node2D

@onready var spawners: Node = $World/Spawners
@onready var timer: Timer = $Timer
@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var player: Player = $Player
@onready var world: Node2D = $World

const DEMON_SCENE := preload("res://demon/demon.tscn")

const WEAPONS: Array[Resource] = [
	preload("res://weapons/gun.tscn"),
	preload("res://weapons/machine_gun.tscn"),
	preload("res://weapons/shotgun.tscn"),
]


func randomize_weapon() -> void:
	var weapon := WEAPONS[randi() % len(WEAPONS)]
	player.set_weapon(weapon)


func _process(_delta: float) -> void:
	timer_label.text = str(timer.time_left).pad_zeros(2).pad_decimals(2)


func _on_timer_timeout() -> void:
	randomize_weapon()
	var spawner := spawners.get_child(randi() % spawners.get_child_count())
	var demon = DEMON_SCENE.instantiate()
	demon.global_position = spawner.global_position
	add_child(demon)
