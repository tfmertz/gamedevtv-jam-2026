extends Node2D
# Autoloaded as "GameManager"

signal scene_changing
signal scene_changed

@onready var camera: Camera2D = $Camera2D
@onready var _color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var paused_label: Label = $CanvasLayer/CenterContainer/PausedLabel

## Optional. Leave empty and set Godot's normal "Main Scene"
## in Project Settings instead. If set, this path loads on startup.
@export var initial_scene_path: String = ""
@export var scrap_scene: PackedScene = preload("res://scene/scrap.tscn")

var is_transitioning := false
var is_spawning_scrap := false
var stop_player_control := false

var flash_tween: Tween
var start_color := Color(0, 0, 0, 0)

func _ready() -> void:

	if initial_scene_path != "":
		# Defer: can't change_scene during the autoload's own _ready.
		_change_to(initial_scene_path)
	else:
		fade_in(3)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var scene_tree := get_tree()
		scene_tree.paused = !scene_tree.paused
		_color_rect.color = start_color
		if scene_tree.paused:
			_color_rect.color.a = 0.5
			paused_label.show()
		else:
			paused_label.hide()
		

func pause_player_control(duration: float) -> void:
	stop_player_control = true
	await get_tree().create_timer(duration).timeout
	stop_player_control = false
	# Start boss music
	AudioManager.cross_fade_music(AudioManager._boss_player)

func fade_out(duration := 1.0) -> void:
	var tween := create_tween()
	tween.tween_property(_color_rect, "color:a", 1.0, duration)
	await tween.finished

func fade_in(duration := 1.0) -> void:
	var tween := create_tween()
	_color_rect.color.a = 1
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

	# Disable objects
	var scene_tree = get_tree()
	scene_tree.paused = true
	await fade_out()
	await _change_to(scene_path)

	scene_changed.emit()
	await fade_in()
	scene_tree.paused = false
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
		get_tree().current_scene.call_deferred("add_child", scrap)
	
	set_deferred("is_spawning_scrap", false)

func scrap_chance_calculator(fleet_size: int) -> float:
	var chance = 0.37
	if fleet_size < 2:
		chance = 1
	elif fleet_size < 4:
		chance = 0.5
	else:
		chance -= fleet_size * 0.015
	return chance
