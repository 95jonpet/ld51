extends Node2D

@onready var spawners: Node = $Spawners
@onready var timer: Timer = $Timer
@onready var timer_label: Label = $CanvasLayer/TimerLabel

const DEMON_SCENE := preload("res://demon/demon.tscn")


func _process(_delta: float) -> void:
	timer_label.text = str(timer.time_left).pad_zeros(2).pad_decimals(2)


func _on_timer_timeout() -> void:
	var spawner := spawners.get_child(randi() % spawners.get_child_count())
	var demon = DEMON_SCENE.instantiate()
	demon.global_position = spawner.global_position
	add_child(demon)
