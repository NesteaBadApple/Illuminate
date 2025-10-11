extends Area2D

@export var light_increase: float = 10.0  # how much the player light grows

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.increase_light()
		queue_free()  # disappear after collected
