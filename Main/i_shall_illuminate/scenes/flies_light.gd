extends PointLight2D

@export var pulse_speed: float = 1.0   # seconds per full pulse
@export var min_energy: float = 0.5
@export var max_energy: float = 1

var t: float = 0.0

func _ready() -> void:
	set_process(true)

func start_pulsing():
	set_process(true)

func _process(delta: float) -> void:
	t += delta * TAU / pulse_speed  # TAU = 2π
	energy = lerp(min_energy, max_energy, (sin(t) + 1.0) / 2.0)
