extends Area2D

signal crystal_lit  # 🔔 Emitted when this crystal is lit

@onready var light_node: PointLight2D = $PointLight2D
var lit: bool = false

func _ready() -> void:
	# Crystal starts unlit
	light_node.energy = 0
	# Register globally
	CrystalManager.register_crystal(self)
	# Connect to manager so it updates when lit
	connect("crystal_lit", Callable(CrystalManager, "crystal_lit"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not lit:
		lit = true
		var tween = create_tween()
		tween.tween_property(light_node, "energy", 1.0, 0.5)
		emit_signal("crystal_lit")  # 🔔 Notify manager
