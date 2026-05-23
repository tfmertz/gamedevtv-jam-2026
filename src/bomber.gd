extends Enemy

@onready var attack_timer: Timer = $AttackTimer
@onready var sprite_2d: Sprite2D = $Sprite2D

## How long to wait until attacking
@export var attack_delay := 2
@export var initial_move_distance := 500

var is_attacking := false
var direction := Vector2.LEFT
var max_speed := 2000

func _ready() -> void:
	# call base class to wire events
	super()

	# our initial move into position
	var tween = move_to(position + direction * initial_move_distance, attack_delay)
	await tween.finished
	_attack()
	

func _move(delta: float) -> void:
	rotation = direction.angle()
	if is_attacking:
		# speed is really accel here
		velocity += direction * speed * delta
		# limit velocity to max_speed
		velocity = velocity.limit_length(max_speed)
		
		# this should never happen, we only accel in attack
		if not velocity.is_zero_approx():
			position += velocity * delta
	

func _attack() -> void:
	await flash()
	is_attacking = true
	# get player and set direction
	var player = get_tree().get_first_node_in_group("player")
	# set our new direction
	if player:
		direction = position.direction_to(player.position)
	
	# set movement, then accel on top in _move
	velocity = direction * speed
