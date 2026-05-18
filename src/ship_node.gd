class_name ShipNode extends Area2D

@onready var bullet_scene : PackedScene = preload("res://scene/bullet.tscn")

enum ShipType {GUN, SHIELD, MOTHER}

var speed := 250
var ship_type: ShipType
var velocity := Vector2.ZERO
var velocity_dir := Vector2.ZERO
var on_path := false
var position_target := Vector2.ZERO
var hp: int
var initial_speed := 0
var screen_size: Rect2
var enemy_z =12
var player_z =11
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_speed = speed
	screen_size = get_viewport_rect()
	$bullet_timer.start()


func set_velocity_dir(new_vel_dir) -> void:
	velocity_dir = new_vel_dir


func set_on_path() -> void:
	on_path = true


func set_position_target(new_target) -> void:
	position_target = new_target


func set_ship_type(new_type) -> void:
	ship_type = new_type
	if ship_type == ShipType.GUN:
		$sprite.animation = "gun"
		hp = 1
		z_index=player_z
	elif ship_type == ShipType.SHIELD:
		$sprite.animation = "shield"
		hp = 1
		z_index=player_z
	elif ship_type == ShipType.MOTHER:
		$sprite.animation = "mothership-3hp"
		hp = 3
		z_index=player_z
	else:
		assert(false, "invalid ship type")


func start(pos):
	position = pos
	show()
	
	if ship_type == ShipType.GUN:
		$hitbox_gun.disabled = false
		
	elif ship_type == ShipType.SHIELD:
		$hitbox_shield.disabled = false
	
	elif ship_type == ShipType.MOTHER:
		$hitbox_mother.disabled = false
	else:
		assert(false, "invalid ship type")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	speed = initial_speed
	# if we're a child ship node and going to our spot
	if on_path:
		# if we're not next to our spot
		if position.distance_to(position_target) > 5:
			# recalc our dir to our spot
			velocity_dir = position.direction_to(position_target)
			# increase speed for travel
			speed = initial_speed * 2
		
	
	# Only move if velocity_dir is a meaningful number
	if not velocity_dir.is_zero_approx():
		# calculate ship velocity
		velocity = velocity_dir * speed
	else:
		# zero out velocity to make sure we're stopped
		velocity = Vector2.ZERO
	
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.size.x)
	position.y = clamp(position.y, 0, screen_size.size.y)


func _on_bullet_timer_timeout() -> void:
	if ship_type != ShipType.SHIELD:
		var bullet = bullet_scene.instantiate()
		bullet.position = position
		get_tree().get_root().add_child(bullet)
		bullet.set_bullet_type(Bullet.BulletType.PLAYER)
