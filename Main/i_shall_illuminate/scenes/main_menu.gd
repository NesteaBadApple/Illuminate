extends CanvasLayer

@onready var start_button = $VBoxContainer/Start
@onready var quit_button = $VBoxContainer/Quit

func _ready():
	start_button.connect("pressed", Callable(self, "_on_start_pressed"))
	quit_button.connect("pressed", Callable(self, "_on_quit_pressed"))

func _on_start_pressed():
	# Load your main game scene
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed():
	get_tree().quit()
