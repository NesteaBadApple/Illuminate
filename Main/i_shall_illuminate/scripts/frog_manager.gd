extends Node

@export var frog_scene: PackedScene           # Assign Frog.tscn here
@export var spawn_interval: float = 5.0       # seconds between spawns
@export var max_frogs: int = 5                # limit to prevent lag

@onready var spawn_points: Array[Marker2D] = []
@onready var spawn_timer: Timer = Timer.new()

var active_frogs: Array = []

func _ready() -> void:
	# collect spawn markers
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)

	add_child(spawn_timer)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.connect("timeout", _on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	if active_frogs.size() < max_frogs:
		spawn_random_frog()

func spawn_random_frog() -> void:
	if spawn_points.is_empty():
		print("⚠️ No spawn points found!")
		return
	var random_point = spawn_points.pick_random()
	print("🐸 Spawning frog at:", random_point.global_position)
	spawn_frog(random_point.global_position)

func spawn_frog(pos: Vector2) -> void:
	if frog_scene == null:
		print("⚠️ frog_scene not assigned!")
		return

	var frog = frog_scene.instantiate()
	add_child(frog)
	frog.global_position = pos
	print("✅ Frog spawned successfully!")

func _on_frog_removed(frog):
	active_frogs.erase(frog)
