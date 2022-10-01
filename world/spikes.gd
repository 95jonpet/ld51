extends Area2D

const SPIKE_HIT_SOUND := preload("res://world/spike_hit.wav")


func _on_spikes_body_entered(body: Node2D) -> void:
	if body.has_method("hurt"):
		AudioPlayer.play(SPIKE_HIT_SOUND)
		body.call("hurt")
