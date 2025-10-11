extends CharacterBody2D

@export var speed: float = 100.0
@export var sprint_multiplier: float = 1.5
@export var stamina_max: float = 100.0
@export var stamina_drain_rate: float = 25.0   # per second
@export var stamina_recover_rate: float = 15.0  # per second

@onready var stamina_bar: TextureProgressBar = $"../UI/Stamina_Bar"
var stamina: float = stamina_max
var is_sprinting: bool = false


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	is_sprinting = Input.is_action_pressed("sprint") and stamina > 0.0 and direction != Vector2.ZERO

	var current_speed := speed
	if is_sprinting:
		current_speed *= sprint_multiplier
		stamina -= stamina_drain_rate * delta
	else:
		stamina += stamina_recover_rate * delta

	stamina = clamp(stamina, 0.0, stamina_max)
	velocity = direction * current_speed
	move_and_slide()

	# Update the bar smoothly
	update_sprint_bar()


func update_sprint_bar() -> void:
	if stamina_bar:
		stamina_bar.value = stamina
