extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var jump_timer: Timer = $JumpTimer
@onready var attack_buffer_timer: Timer = $AttackBufferTimer
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer

@export var jump_speed: float = 100.0
@export var detection_delay: float = 0.5
@export var attack_buffer: float = 0.3
@export var attack_cooldown: float = 1.5
@export var detection_radius: float = 150.0
@export var jump_duration: float = 0.4

var target: Node2D = null
var has_target: bool = false
var is_jumping: bool = false
var can_attack: bool = true
var jump_timer_elapsed: float = 0.0
var jump_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	anim.play("idle")
	detection_area.monitoring = true
	detection_area.monitorable = true

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

		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision.get_collider().is_in_group("player"):
				_on_player_hit(collision.get_collider())
				break

	# 🧠 Continuous detection check
	if not is_jumping and not attack_cooldown_timer.time_left and can_attack and target and is_instance_valid(target):
		var distance = global_position.distance_to(target.global_position)
		if distance <= detection_radius:
			_try_attack_target()
		else:
			_reset_to_idle()

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
	if not can_attack or is_jumping or attack_buffer_timer.time_left > 0.0 or jump_timer.time_left > 0.0:
		anim.play("alert")
		return

	anim.play("idle")
	_face_target()
	jump_timer.start(detection_delay)

func _on_jump_timer_timeout() -> void:
	if target and is_instance_valid(target) and has_target and can_attack:
		anim.play("charge")
		attack_buffer_timer.start(attack_buffer)

func _on_attack_buffer_timeout() -> void:
	if target and is_instance_valid(target) and has_target and can_attack:
		_jump_toward_target()

func _jump_toward_target() -> void:
	is_jumping = true
	can_attack = false
	jump_timer_elapsed = 0.0
	anim.play("jump")
	_face_target()
	jump_direction = (target.global_position - global_position).normalized()
	print("🐸 Jumping toward player!")

func _start_attack_cooldown() -> void:
	attack_cooldown_timer.start(attack_cooldown)
	print("⏳ Frog cooling down...")

func _on_attack_cooldown_timeout() -> void:
	can_attack = true
	print("🐸 Frog ready to attack again!")

func _face_target() -> void:
	if not target:
		return
	anim.flip_h = target.global_position.x < global_position.x

func _reset_to_idle() -> void:
	if not is_jumping and not attack_buffer_timer.time_left and not jump_timer.time_left:
		anim.play("idle")

func _on_animation_finished() -> void:
	if anim.animation == "landing" and not is_jumping:
		_reset_to_idle()

func _on_player_hit(player: Node2D) -> void:
	if player.has_method("reset_light"):
		player.reset_light()
		print("💀 Frog hit the player! Light reset.")
