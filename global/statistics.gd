extends Node

var enemies_killed: int = 0
var levels_completed: int = 0


func reset() -> void:
	enemies_killed = 0
	levels_completed = 0


func get_enemies_killed() -> int:
	return enemies_killed


func get_levels_completed() -> int:
	return levels_completed


func increment_enemies_killed() -> void:
	enemies_killed += 1


func increment_levels_completed() -> void:
	levels_completed += 1
