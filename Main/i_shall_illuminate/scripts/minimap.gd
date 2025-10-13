extends Control

@export var map_scale: float = 0.1
@onready var player_icon: ColorRect = $PlayerIcon
@onready var crystal_container: Node2D = $CrystalMarkers
@export var fog_overlay: TextureRect

var player: Node2D
var crystals: Array[Node2D] = []
var markers: Dictionary = {}
var fog_texture: ImageTexture
var fog_image: Image

const REVEAL_RADIUS := 12  # size of revealed circle

func _ready() -> void:
	await get_tree().process_frame  # wait for TileMap to spawn crystals

	player = get_tree().get_root().find_node("Player", true, false)
	crystals = get_tree().get_nodes_in_group("Crystal")

	for crystal in crystals:
		var marker := ColorRect.new()
		marker.color = Color(0.3, 0.8, 1.0, 1.0)
		marker.size = Vector2(4, 4)
		crystal_container.add_child(marker)
		markers[crystal] = marker

	_create_fog()

	if Engine.has_singleton("CrystalManager"):
		CrystalManager.connect("crystal_count_changed", Callable(self, "_on_crystal_update"))

func _create_fog() -> void:
	var size = fog_overlay.size
	fog_image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	fog_image.fill(Color(0, 0, 0, 0.8))
	fog_texture = ImageTexture.create_from_image(fog_image)
	fog_overlay.texture = fog_texture

func _on_crystal_update(total: int, lit: int) -> void:
	for crystal in crystals:
		if crystal.has_method("is_lit") and crystal.is_lit():
			_reveal_area(crystal.global_position)

func _process(delta: float) -> void:
	if not player:
		return

	player_icon.position = _world_to_minimap(player.global_position)

	for crystal in crystals:
		if not is_instance_valid(crystal):
			continue
		var marker = markers.get(crystal)
		if marker:
			marker.position = _world_to_minimap(crystal.global_position)
			if crystal.has_method("is_lit") and crystal.is_lit():
				marker.color = Color(1, 1, 0, 1)  # yellow if lit

	# OPTIONAL: reveal fog as player moves
	_reveal_area(player.global_position)

func _reveal_area(world_pos: Vector2) -> void:
	if not fog_image:
		return

	var map_pos = _world_to_minimap(world_pos)
	var px = int(map_pos.x)
	var py = int(map_pos.y)

	fog_image.lock()
	for x in range(px - REVEAL_RADIUS, px + REVEAL_RADIUS):
		for y in range(py - REVEAL_RADIUS, py + REVEAL_RADIUS):
			if x >= 0 and x < fog_image.get_width() and y >= 0 and y < fog_image.get_height():
				var dist = Vector2(x - px, y - py).length()
				if dist < REVEAL_RADIUS:
					var alpha = clamp(1.0 - (dist / REVEAL_RADIUS), 0.0, 1.0)
					var current = fog_image.get_pixel(x, y)
					fog_image.set_pixel(x, y, Color(current.r, current.g, current.b, current.a * (1.0 - alpha)))
	fog_image.unlock()
	fog_texture.update(fog_image)

func _world_to_minimap(world_pos: Vector2) -> Vector2:
	return world_pos * map_scale
