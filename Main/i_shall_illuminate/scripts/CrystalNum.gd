extends Label

func _ready() -> void:
	await get_tree().process_frame  # Wait one frame for crystals to spawn
	CrystalManager.connect("crystal_count_changed", _on_crystal_count_changed)
	_on_crystal_count_changed(CrystalManager.total_crystal, CrystalManager.lit_crystal)

func _on_crystal_count_changed(total: int, lit: int) -> void:
	text = "%d / %d" % [lit, total]
