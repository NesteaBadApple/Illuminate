extends Node

@onready var dark_light := $DarkMode

func _ready() -> void:
	CrystalManager.darkmode = dark_light
