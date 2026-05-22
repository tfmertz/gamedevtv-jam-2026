extends Enemy

@onready var attack_timer: Timer = $AttackTimer
@onready var collision_shape_2d: CollisionShape2D = $ExplosionArea/CollisionShape2D
@onready var explosion_area: Area2D = $ExplosionArea

## How long to wait until attacking
@export var attack_delay := 2
@export var explosion_radius := 50

var is_attacking := false

func _ready() -> void:
	collision_shape_2d.shape.radius = explosion_radius
	attack_timer.wait_time = attack_delay
	attack_timer.start()

func _move(delta: float) -> void:
	if not is_attacking:
		# speed is really accel here
		velocity += Vector2.LEFT * speed * delta
	else:
		# quick drag
		velocity = velocity.move_toward(Vector2.ZERO, 500 * delta)
	
	if not velocity.is_zero_approx():
		position += velocity * delta

func _attack() -> void:
	is_attacking = true
	await flash()
	is_attacking = false
	# launch attack
	speed = 400
	# clean enemy if they didn't collide
	get_tree().create_timer(5).timeout.connect(queue_free)

func _die() -> void:
	# check out AOE and deal damage
	var areas = explosion_area.get_overlapping_areas()
	for area in areas:
		if area.has_method("take_damage"):
			area.take_damage(attack)
	queue_free()

func _on_attack_timer_timeout() -> void:
	_attack()


func _on_area_entered(area: Area2D) -> void:
	# if we hit something that can take damage
	if area is ShipNode:
		# explode
		_die()
