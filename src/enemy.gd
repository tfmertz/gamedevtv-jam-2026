# This class is not meant to be used on Nodes, but to be extended
@abstract
class_name Enemy
extends Area2D

@export var health := 1
@export var attack := 1
@export var speed := 100

var ship_explosion_vfx : PackedScene = preload("res://scene/ship_explosion.tscn")

var velocity := Vector2.ZERO
var move_tween : Tween

func _physics_process(delta: float) -> void:
	if position.x < -50:
		# silently die offscreen
		queue_free()
	
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

func _die() -> void:
	var explosion_vfx := ship_explosion_vfx.instantiate()
	explosion_vfx.position = position
	get_parent().add_child(explosion_vfx)
	queue_free()
