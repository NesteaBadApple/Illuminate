extends Node2D

@export var dialogue_lines: Array[String] = [
	"Hey there, traveler!",
	"It's so dark in here",
	"Maybe you can try to 
	light up those crystals",
	"There are frogs that take 
	your light so just avoid them",
	"If you ran out of light,
	just gather some fire spirits",
	"I guess that's all for 
	the tutorial i guess"
]

var player_in_range := false
var current_line := 0

@onready var dialogue_bubble = $dialogue_bubble
@onready var dialogue_label = $dialogue_bubble/Panel/Label

func _ready():
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))
	$Area2D.connect("body_exited", Callable(self, "_on_body_exited"))
	dialogue_bubble.visible = false

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_in_range = false
		hide_dialogue()

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		show_next_line()
		print("clicked")

func show_next_line():
	if current_line < dialogue_lines.size():
		dialogue_label.text = dialogue_lines[current_line]
		dialogue_bubble.visible = true
		current_line += 1
	else:
		hide_dialogue()
		current_line = 0

func hide_dialogue():
	dialogue_bubble.visible = false
