extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var jump_timer: Timer = $JumpTimer
@onready var attack_buffer_timer: Timer = $AttackBufferTimer
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer

@export var jump_speed: float = 100.0
@export var detection_delay: float = 2.5   # Time before starting attack
@export var attack_buffer: float = .3       # Time between charge and jump
@export var attack_cooldown: float = .1
@export var detection_radius: float = 250.0
@export var jump_duration: float = 0.4
@export var sprite_faces_right: bool = true

var target: Node2D = null
var has_target: bool = false
var is_jumping: bool = false
var can_attack: bool = true
var jump_timer_elapsed: float = 0.0
var jump_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	anim.play("idle")
	anim.flip_h
	detection_area.connect("body_entered", _on_body_entered)
	detection_area.connect("body_exited", _on_body_exited)
	jump_timer.connect("timeout", _on_jump_timer_timeout)
	attack_buffer_timer.connect("timeout", _on_attack_buffer_timeout)
	attack_cooldown_timer.connect("timeout", _on_attack_cooldown_timeout)
	anim.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _physics_process(delta: float) -> void:
	if is_jumping:
		jump_timer_elapsed += delta
		velocity = jump_direction * jump_speed
		move_and_slide()

		if jump_timer_elapsed >= jump_duration:
			is_jumping = false
			velocity = Vector2.ZERO
			anim.play("landing")
			_start_attack_cooldown()

	# Continuously track player
	if not is_jumping and target and is_instance_valid(target):
		_face_target()


# =======================
# 🎯 Detection
# =======================
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body
		has_target = true
		print("🐸 Frog detected player!")
		_try_attack_target()

func _on_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		has_target = false
		_reset_to_idle()

func _try_attack_target() -> void:
	if not can_attack or is_jumping or jump_timer.time_left > 0.0:
		return

	can_attack = false
	anim.play("alert")
	_face_target()

	# 🕒 Wait before attacking
	jump_timer.start(detection_delay)
	print("⚠️ Frog is charging attack...")

func _on_jump_timer_timeout() -> void:
	if target and is_instance_valid(target) and has_target:
		anim.play("alert")
		attack_buffer_timer.start(attack_buffer)
		print("💢 Frog charging jump!")


# =======================
# 🐸 Jump Behavior
# =======================
func _on_attack_buffer_timeout() -> void:
	if target and is_instance_valid(target) and has_target:
		_jump_toward_target()

func _jump_toward_target() -> void:
	is_jumping = true
	jump_timer_elapsed = 0.0
	anim.play("jump")
	_face_target()
	jump_direction = (target.global_position - global_position).normalized()

	# Pass through player but not walls
	_set_collision_with_player(false)

	print("💨 Frog jumps toward player!")

func _start_attack_cooldown() -> void:
	attack_cooldown_timer.start(attack_cooldown)
	print("⏳ Frog cooling down...")

func _on_attack_cooldown_timeout() -> void:
	can_attack = true
	print("✅ Frog ready again!")
	anim.play("alert")
	
	

# =======================
# 🧠 Helpers
# =======================
func _face_target() -> void:
	if not target or not is_instance_valid(target):
		return

	var target_is_left := target.global_position.x < global_position.x
	if sprite_faces_right:
		anim.flip_h = not target_is_left
	else:
		anim.flip_h = target_is_left

func _reset_to_idle() -> void:
	if not is_jumping and not jump_timer.time_left and not attack_buffer_timer.time_left:
		anim.play("idle")

func _set_collision_with_player(enabled: bool) -> void:
	# Assume player = layer 1, wall = layer 2
	if enabled:
		collision_mask = 0b11  # collide with player & wall
	else:
		collision_mask = 0b10  # only walls

func _on_animation_finished() -> void:
	if anim.animation == "landing" and not is_jumping:
		_set_collision_with_player(true)
		_reset_to_idle()
		
func _on_player_hit(player: Node2D) -> void:
	if player.has_method("reduce_light"):
		player.shrink_light()
		print("💀 Frog hit the player! Light reduced.")
