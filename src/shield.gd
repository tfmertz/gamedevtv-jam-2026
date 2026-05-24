extends Area2D

# start as 0 which means shield is disabled
@export var health := 0
@export var protecting_shape: CollisionShape2D
@export var is_enemy := false
@export var auto_init := false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var tween : Tween
var tween_scale : Tween

var initial_scale = Vector2.ONE

func _ready() -> void:
	if health > 0 and auto_init:
		set_active(health)

func set_active(new_health: int) -> void:
	# if we aren't started, wait til next frame
	if not sprite_2d:
		call_deferred("set_active", new_health)
		return
	
	# assign the layer based on the side
	if is_enemy:
		set_collision_layer_value(2, true)
		initial_scale = Vector2(0.65, 0.65)
		collision_shape_2d.shape.radius = 40
	else:
		set_collision_layer_value(1, true)
		initial_scale = Vector2.ONE
		collision_shape_2d.shape.radius = 61
	
	# set health
	health = new_health
	# turn on visuals and collision
	sprite_2d.scale = Vector2.ZERO
	sprite_2d.visible = true
	scale_shield(initial_scale, 0.45)
	collision_shape_2d.disabled = false

func take_damage(damage: int, source: Area2D) -> void:
	health -= damage
	if health <= 0:
		# disable our protection
		collision_shape_2d.set_deferred("disabled", true)
		scale_shield(Vector2.ZERO, 0.2)
	else:
		flash()

func scale_shield(new_scale, duration) -> Tween:
	tween_scale = create_tween()
	tween_scale.tween_property(sprite_2d, "scale", new_scale, duration)
	return tween_scale

func flash() -> void:
	if tween and tween.is_running():
		return
	
	tween = create_tween()
	tween.set_loops(2)
	tween.tween_property(sprite_2d, "modulate:a", 0.5, 0.05)
	tween.tween_property(sprite_2d, "modulate:a", 1, 0.05)
