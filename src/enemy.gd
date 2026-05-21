# This class is not meant to be used on Nodes, but to be extended
@abstract
class_name Enemy
extends Area2D

@export var health := 1
@export var attack := 1
@export var speed := 100

var velocity := Vector2.ZERO

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
	tween.tween_property(self, "modulate:a", 0.5, 0.2)
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	await tween.finished

func _die() -> void:
	pass
