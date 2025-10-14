extends Node

@onready var dark_light := $DarkMode
@onready var pause_menu := $PauseMenu  # CanvasLayer with Panel + Buttons
@onready var resume_button := $PauseMenu/Panel/VBoxContainer/resume
@onready var quit_button := $PauseMenu/Panel/VBoxContainer/quit
var is_paused: bool = false

func _ready() -> void:
	CrystalManager.darkmode = dark_light
	

func _process(delta: float) -> void:
	# Toggle pause with Esc
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()

func _toggle_pause() -> void:
	is_paused = not is_paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused

func _on_resume_pressed() -> void:
	_toggle_pause()  # Resumes the game

func _on_quit_pressed() -> void:
	get_tree().quit()  # Or go back to main menu scene
