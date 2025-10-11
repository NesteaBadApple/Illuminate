extends Node

var total_crystal: int = 0
var lit_crystal: int = 0

signal crystal_count_changed(total: int, lit: int)

func register_crystal(crystal: Node) -> void:
	total_crystal += 1
	print("Registered crystal. Total:", total_crystal)
	emit_signal("crystal_count_changed", total_crystal, lit_crystal)

func crystal_lit() -> void:
	lit_crystal += 1
	print("Crystal lit! Count:", lit_crystal, "/", total_crystal)
	emit_signal("crystal_count_changed", total_crystal, lit_crystal)
