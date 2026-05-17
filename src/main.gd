extends Node2D

@export var default_scene: PackedScene
@onready var scene_root: Node2D = $SceneRoot
@onready var color_rect: ColorRect = $Transitions/ColorRect

var is_transitioning := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene_root.add_child(default_scene.instantiate())
	fade_in(3)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func fade_out(duration = 1.0):
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, duration)
	await tween.finished

func fade_in(duration = 1.0):
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, duration)
	await tween.finished

func load_scene(scene_path):
	await fade_out()
	for child in scene_root.get_children():
		child.queue_free()
	var new_scene := load(scene_path)
	scene_root.add_child(new_scene.instantiate())
	await fade_in()
