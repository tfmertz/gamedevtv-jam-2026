extends Enemy

@onready var attack_timer: Timer = $AttackTimer

@export var bullet_scene : PackedScene
@export var attack_delay := .05
@export var attack_spread := 10
@export var clip_size := 8
@export var movement_duration := 1.25
@export var movement_spread := 25
@export var movement_distance := 400

var is_attacking := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not bullet_scene:
		assert(bullet_scene != null, "Bullet scene needs to be defined to shoot!")

	set_new_target()

func _process(delta: float) -> void:
	if not move_tween.is_running() and not is_attacking:
		set_new_target()

func _attack() -> void:
	# spawn "clip_size" bullets at "spread" vectors
	for i in range(clip_size):
		var new_bullet : Bullet = bullet_scene.instantiate()
		new_bullet.position = position
		get_tree().root.add_child(new_bullet)
		new_bullet.set_bullet_type(Bullet.BulletType.ENEMY_2)
		new_bullet.direction = random_direction_around(Vector2.LEFT, attack_spread)
		attack_timer.wait_time = attack_delay
		attack_timer.start()
		# wait "attack_deplay" for next bullet instantiation
		await attack_timer.timeout

# move to a new position, flash, and then bust your load
func set_new_target() -> void:
	# random angle LEFT between 
	var dir = random_direction_around(Vector2.LEFT, movement_spread)
	var new_target = (dir * movement_distance) + position
	
	# move_to is from base Enemy class
	var tween = move_to(new_target, movement_duration)
	
	# wait until movement tween is done to attack
	await tween.finished
	is_attacking = true
	# flash is from base Enemy class
	await flash()
	# wait for attack to finish until moving again
	await _attack()
	is_attacking = false
	
