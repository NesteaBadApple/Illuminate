extends Area2D


func _on_body_entered(body: Node) -> void:
	# Only react to the player's hitbox
	if body.is_in_group("player"):
		if body.has_method("increase_light"):
			body.increase_light()
		queue_free() # Remove the spirit
