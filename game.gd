extends Node2D

@onready var timer: Timer = $Timer
@onready var timer_label: Label = $CanvasLayer/TimerLabel


func _process(_delta: float) -> void:
	timer_label.text = str(timer.time_left).pad_zeros(2).pad_decimals(2)
