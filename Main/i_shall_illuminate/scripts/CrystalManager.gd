extends Node

var total_crystal: int = 0
var lit_crystal: int = 0
var darkmode: DirectionalLight2D = null

signal crystal_count_changed(total: int, lit: int)

func register_crystal(crystal: Node) -> void:
	total_crystal += 1
	print("Registered crystal. Total:", total_crystal)
	emit_signal("crystal_count_changed", total_crystal, lit_crystal)

func crystal_lit() -> void:
	lit_crystal += 1
	print("Crystal lit! Count:", lit_crystal, "/", total_crystal)
	emit_signal("crystal_count_changed", total_crystal, lit_crystal)
	
	if lit_crystal >= total_crystal and total_crystal > 0:
		_clear_dark_mode()

func _clear_dark_mode() -> void:
	if darkmode:
		print("✨ All crystals lit! Darkness fading away...")
		var tween := create_tween()
		tween.tween_property(darkmode, "energy", 0.0, 1.5) # fade out over 1.5 seconds
		tween.tween_callback(func(): darkmode.visible = false)
	else:
		print("⚠️ No darkmode assigned!")
