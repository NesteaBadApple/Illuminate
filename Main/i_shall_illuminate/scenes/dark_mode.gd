extends DirectionalLight2D

func _ready() -> void:
	CrystalManager.connect("complete_light", light_energy)
