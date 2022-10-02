class_name GameOverScreen
extends Control

signal dismissed()

@onready var stats_label: Label = $CenterContainer/VBoxContainer/StatsLabel


func enable() -> void:
	get_tree().paused = true
	visible = true

	var label_format: String = "\n".join([
		"Enemies killed: %d",
		"Levels Completed: %d",
	])
	stats_label.text = label_format % [
		Statistics.get_enemies_killed(),
		Statistics.get_levels_completed(),
	]


func disable() -> void:
	visible = false
	get_tree().paused = false
	dismissed.emit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_unpause"):
		disable()
