extends Area2D


func _on_spikes_body_entered(body: Node2D) -> void:
	if body.has_method("hurt"):
		body.call("hurt")
