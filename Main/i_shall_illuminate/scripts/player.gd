extends CharacterBody2D

# 🏃 Movement & Stamina
@export var speed: float = 100.0
@export var sprint_multiplier: float = 1.5
@export var stamina_max: float = 100.0
@export var stamina_drain_rate: float = 25.0
@export var stamina_recover_rate: float = 15.0
@onready var animation: AnimatedSprite2D = $Sprite2D
@onready var stamina_bar: TextureProgressBar = $"Player UI/Stamina_Bar"
var stamina: float = stamina_max
var is_sprinting: bool = false
@onready var particles: GPUParticles2D = $SprintParticles
# 💡 Player Light
@onready var light_node: PointLight2D = $PlayerLight
@onready var light_bar: TextureProgressBar = $"Player UI/Light_Bar"
var light_max = 5

func _process(delta: float) -> void:
	if Input.is_action_pressed("down"):
		animation.play("front")
	elif Input.is_action_pressed("up"):
		animation.play("back")
	elif Input.is_action_pressed("left"):
		animation.play("left")
	elif Input.is_action_pressed("right"):
		animation.play("right")

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	is_sprinting = Input.is_action_pressed("sprint") and stamina > 0.0 and direction != Vector2.ZERO

	var current_speed := speed
		
	if is_sprinting:
		current_speed *= sprint_multiplier
		stamina -= stamina_drain_rate * delta
		particles.emitting = true
		if direction != Vector2.ZERO:
			particles.rotation = direction.angle() + PI  # opposite direction

	else:
		stamina += stamina_recover_rate * delta
		particles.emitting = false

	stamina = clamp(stamina, 0.0, stamina_max)
	velocity = direction * current_speed
	move_and_slide()

	update_sprint_bar()

# ⚡ Update Stamina Bar
func update_sprint_bar() -> void:
	if stamina_bar:
		stamina_bar.value = stamina

# ✨ When touching a Spirit
func increase_light():
	if not light_node:
		return

	var grow_factor : = .5
	var new_scale = min(light_node.texture_scale + .5, light_max)

	var tween = create_tween()
	tween.tween_property(light_node, "texture_scale", new_scale, 0.3)
	if light_bar:
		light_bar.value = (new_scale / light_max) * light_bar.max_value
	print("✨ Light grew to:", new_scale) 

# 💀 When hit by a Frog
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Frog"):
		$hit.play()
		shrink_light()
	elif body.is_in_group("Spirit"):
		increase_light()
		body.queue_free()

# 🕯️ Shrink Light when hit
func shrink_light():
	if not light_node:
		return

	var shrink_factor := 0.5
	var min_scale := 0.25
	var new_scale = max(light_node.texture_scale - .5, min_scale)

	var tween = create_tween()
	tween.tween_property(light_node, "texture_scale", new_scale, 0.3)
	if light_bar:
		light_bar.value = (new_scale / 5.0) * light_bar.max_value
	print("💀 Light shrunk to:", new_scale)
