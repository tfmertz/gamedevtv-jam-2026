extends Node2D
# Autoloaded as "GameManager"

signal scene_changing
signal scene_changed

@onready var camera: Camera2D = $Camera2D

## Optional. Leave empty and set Godot's normal "Main Scene"
## in Project Settings instead. If set, this path loads on startup.
@export var initial_scene_path: String = ""
@export var scrap_scene: PackedScene = preload("res://scene/scrap.tscn")

var is_transitioning := false
var is_spawning_scrap := false
var stop_player_control := false

var _color_rect: ColorRect
var flash_tween: Tween


func _ready() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 128
	add_child(canvas)

	_color_rect = ColorRect.new()
	_color_rect.color = Color(0, 0, 0, 1)  # opaque; fade in to reveal
	_color_rect.anchor_right = 1.0
	_color_rect.anchor_bottom = 1.0
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(_color_rect)

	if initial_scene_path != "":
		# Defer: can't change_scene during the autoload's own _ready.
		_change_to(initial_scene_path)
	else:
		fade_in(3)

func pause_player_control(duration: float) -> void:
	stop_player_control = true
	await get_tree().create_timer(duration).timeout
	stop_player_control = false

func fade_out(duration := 1.0) -> void:
	var tween := create_tween()
	tween.tween_property(_color_rect, "color:a", 1.0, duration)
	await tween.finished

func fade_in(duration := 1.0) -> void:
	var tween := create_tween()
	tween.tween_property(_color_rect, "color:a", 0.0, duration)
	await tween.finished

func flash(duration := 0.1) -> void:
	if flash_tween and flash_tween.is_running():
		return
	var initial_color := _color_rect.color
	var color = Color(1, 1, 1, 0)
	_color_rect.color = color
	flash_tween = create_tween()
	flash_tween.tween_property(_color_rect, "color:a", 0.5, duration)
	flash_tween.tween_property(_color_rect, "color:a", 0.0, duration)
	await flash_tween.finished
	
	_color_rect.color = initial_color

func shake_camera(shake_strength: float) -> void:
	if camera and camera.has_method("shake"):
		camera.shake(shake_strength)

func load_scene(scene_path: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	scene_changing.emit()

	await fade_out()
	await _change_to(scene_path)

	scene_changed.emit()
	await fade_in()
	is_transitioning = false

# Performs the scene change and waits until the new scene
# is actually loaded because change_scene_to_file is deferred a frame
func _change_to(scene_path: String) -> void:
	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("change_scene_to_file failed (%d): %s" % [err, scene_path])
		return
	# Wait one frame so get_tree().current_scene is the new scene.
	await get_tree().process_frame
	await get_tree().process_frame  # second frame: instantiation settled

func spawn_scrap(pos: Vector2) -> void:
	if is_spawning_scrap:
		return
	is_spawning_scrap = true
	var player_fleet_size = get_tree().get_nodes_in_group("node").size()
	var scrap_chance = scrap_chance_calculator(player_fleet_size)
	if randf_range(0, 1) < scrap_chance:
		var scrap = scrap_scene.instantiate()
		scrap.position = pos
		get_tree().get_root().call_deferred("add_child", scrap)
	
	set_deferred("is_spawning_scrap", false)

func scrap_chance_calculator(fleet_size: int) -> float:
	var chance = 0.35
	if fleet_size < 2:
		chance = 1
	elif fleet_size < 4:
		chance = 0.5
	else:
		chance -= fleet_size * 0.02
	return chance
