extends Enemy

@onready var attack_timer: Timer = $AttackTimer
@onready var sprite_2d: Sprite2D = $Sprite2D

## How long to wait until attacking
@export var attack_delay := 2

var is_attacking := false
var direction := Vector2.LEFT

func _ready() -> void:
	# call base class to wire events
	super()

	attack_timer.wait_time = attack_delay
	attack_timer.start()

func _move(delta: float) -> void:
	if not is_attacking:
		# speed is really accel here
		velocity += direction * speed * delta
	else:
		# quick drag
		velocity = velocity.move_toward(Vector2.ZERO, 1000 * delta)
		#look_at(direction)
	
	if not velocity.is_zero_approx():
		position += velocity * delta

func _attack() -> void:
	is_attacking = true
	# get player and set direction
	var player = get_tree().get_first_node_in_group("player")
	# set our new direction
	if player:
		direction = position.direction_to(player.position)
		# set sprite to right rotation
		sprite_2d.rotation = direction.angle()
		sprite_2d.scale.x *= -1
		#$RayCast2D.target_position = direction
	
	await flash()
	
	is_attacking = false
	# launch attack
	speed *= 2
	# clean enemy if they didn't collide
	get_tree().create_timer(5).timeout.connect(queue_free)

func _on_attack_timer_timeout() -> void:
	_attack()
