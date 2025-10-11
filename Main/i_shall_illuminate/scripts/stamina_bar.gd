extends TextureProgressBar
@onready var tween := create_tween()

func update_sprint_bar() -> void:
	if stamina_bar:
		tween.kill()
		tween = create_tween()
		tween.tween_property(stamina_bar, "value", stamina, 0.1)
