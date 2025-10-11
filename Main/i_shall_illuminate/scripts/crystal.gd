extends Area2D

signal torch_lit  # 🔔 Signal to notify the UI or main scene

@onready var light_node: PointLight2D = $PointLight2D
var lit: bool = false

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not lit:
		lit = true
		var tween = create_tween()
		tween.tween_property(light_node, "energy", 1, 0.5)
		emit_signal("torch_lit")  # 🔔 Notify that this torch has been lit
