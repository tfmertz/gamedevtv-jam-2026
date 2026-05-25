extends Area2D

# start as 0 which means shield is disabled
@export var health := 0
@export var max_health := 0
@export var protecting_shape: CollisionShape2D
@export var is_enemy := false
@export var auto_init := false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var enemy_collision_shape_2d: CollisionShape2D = $EnemyCollisionShape2D

@onready var regen_timer: Timer = $RegenTimer

var tween : Tween
var tween_scale : Tween
var bossshield = false
var target_location
var speed = 150
var base_alpha := 0.0

var initial_scale = Vector2.ONE

func _ready() -> void:
	if health > 0 and auto_init:
		set_active(health)
	target_location=position

func _physics_process(delta: float) -> void:
	if bossshield:
		flyto(delta)

func set_active(new_health: int, new_max_health: int = -1) -> void:
	# if we aren't started, wait til next frame
	if not sprite_2d:
		call_deferred("set_active", new_health)
		return
	
	# assign the layer based on the side
	if is_enemy:
		set_collision_layer_value(2, true)
		initial_scale = Vector2(0.65, 0.65)
		enemy_collision_shape_2d.shape.radius = 40
		enemy_collision_shape_2d.disabled = false
		collision_shape_2d.disabled = true
	else:
		set_collision_layer_value(1, true)
		initial_scale = Vector2.ONE
		collision_shape_2d.shape.radius = 61
		collision_shape_2d.disabled = false
		enemy_collision_shape_2d.disabled = true
	
	# set health
	health = new_health
	if new_max_health <= 0:
		max_health = health
	else:
		max_health = new_max_health
	if base_alpha == 0.0:
		base_alpha = sprite_2d.self_modulate.a
	# turn on visuals and collision
	sprite_2d.scale = Vector2.ZERO
	sprite_2d.visible = true
	scale_shield(initial_scale, 0.45)

func take_damage(damage: int, source: Area2D) -> void:
	health -= damage
	if health <= 0:
		# disable our protection
		collision_shape_2d.set_deferred("disabled", true)
		enemy_collision_shape_2d.set_deferred("disabled", true)
		scale_shield(Vector2.ZERO, 0.2)
	else:
		regen_timer.start()
		await flash()
		if max_health > 0:
			sprite_2d.self_modulate.a = base_alpha * (float(health) / max_health)

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

func flyto(delta: float) -> void: #recieves a target position as vector2
	var dir = position.direction_to(target_location)
	# sets a temporary speed equal to arrive at location exactly
	if position.distance_to(target_location) > 5:
		position += dir * speed * delta


func _on_regen_timer_timeout() -> void:
	if health == 0:
		set_active(1, max_health)
	else:
		if health < max_health:
			take_damage(-1, self)
		else:
			regen_timer.stop()
