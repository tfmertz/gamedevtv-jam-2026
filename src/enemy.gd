# This class is not meant to be used on Nodes, but to be extended
@abstract
class_name Enemy
extends Area2D

@export var health := 1
@export var attack := 1
@export var speed := 100
@export var explosion_damage := 1
@export var explosion_radius := 50

var ship_explosion_vfx : PackedScene = preload("res://scene/ship_explosion.tscn")

var velocity := Vector2.ZERO
var move_tween : Tween
var is_dying := false

func _ready() -> void:
	# hook up explosion logic
	area_entered.connect(_on_area_entered)
	
func _physics_process(delta: float) -> void:
	_move(delta)

func _move(delta: float) -> void:
	pass
	
func _attack() -> void:
	pass
	
func take_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		_die()

func flash():
	# play flash
	var tween := create_tween()
	tween.set_loops(3)
	tween.tween_property(self, "modulate:a", 0.5, 0.1)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	await tween.finished

func move_to(target: Vector2, duration: float = 0.5,
	trans: Tween.TransitionType = Tween.TRANS_CUBIC,
	ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> Tween:
	if move_tween and move_tween.is_valid():
		move_tween.kill()
	move_tween = create_tween()
	move_tween.tween_property(self, "position", target, duration)\
		.set_trans(trans)\
		.set_ease(ease_type)
	return move_tween

# Helper to get a random direction within a spread
func random_direction_around(base: Vector2, spread_degrees: float = 45.0) -> Vector2:
	var angle_offset = randf_range(-deg_to_rad(spread_degrees), deg_to_rad(spread_degrees))
	return base.normalized().rotated(angle_offset)

func is_on_screen(world_pos: Vector2) -> bool:
	var transform := get_viewport().get_canvas_transform()
	var screen_pos := transform * world_pos
	return get_viewport_rect().has_point(screen_pos)

func _die(explode: bool = false) -> void:
	if is_dying:
		return
	is_dying = true
	# Request a scrap spawn from GameManager
	GameManager.spawn_scrap(position)

	var explosion_vfx := ship_explosion_vfx.instantiate()
	explosion_vfx.position = position
	# set the explosion to do damage, this will automatically
	# show a damage visual and handle dealing the damage
	if explosion_damage > 0 and explode:
		explosion_vfx.damage = explosion_damage
		explosion_vfx.radius = explosion_radius
	get_parent().call_deferred("add_child", explosion_vfx)
	queue_free()

# handles exploding from player ship/nodes. Not for regular damage detectiion
# see take_damage
func _on_area_entered(area: Area2D) -> void:
	var is_explosion := false
	# only explode on collisions with nodes or player
	if area.is_in_group("node"):
		is_explosion = true
	_die(is_explosion)
