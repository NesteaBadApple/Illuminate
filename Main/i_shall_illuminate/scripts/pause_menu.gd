extends CanvasLayer

@onready var pause_menu = $Panel

func _ready():
	pause_menu.visible = false

func _input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			resume_game()
		else:
			pause_game()

func pause_game():
	pause_menu.visible = true
	get_tree().paused = true
	print("⏸️ Game paused")

func resume_game():
	pause_menu.visible = false
	get_tree().paused = false
	print("▶️ Game resumed")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_resume_pressed() -> void:
	resume_game()
