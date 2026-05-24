class_name ShipNode extends Area2D

@onready var bullet_scene : PackedScene = preload("res://scene/bullet.tscn")
@onready var scrap_scene : PackedScene = preload("res://scene/scrap.tscn")

enum ShipType {GUN, SHIELD, MOTHER}

var speed := 250
var ship_type: ShipType
var velocity := Vector2.ZERO
var velocity_dir := Vector2.ZERO
var on_path := false
var position_target := Vector2.ZERO
var health: int
var initial_speed := 0
var screen_size: Rect2
var invuln_duration := 1
var parent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_speed = speed
	screen_size = get_viewport_rect()
	$bullet_timer.start()

func register_parent(new_parent) -> void:
	parent = new_parent


func set_velocity_dir(new_vel_dir) -> void:
	velocity_dir = new_vel_dir


func set_on_path() -> void:
	on_path = true


func set_position_target(new_target) -> void:
	position_target = new_target


func set_ship_type(new_type) -> void:
	ship_type = new_type
	show()
	$InvulnerabilityTimer.wait_time = invuln_duration
	if ship_type == ShipType.GUN:
		$sprite.animation = "gun"
		$hitbox_gun.disabled = false
		health = 1
	elif ship_type == ShipType.SHIELD:
		$sprite.animation = "shield"
		health = 1
		$hitbox_shield.disabled = false
		$Shield.set_active(3)
	elif ship_type == ShipType.MOTHER:
		$sprite.animation = "mothership-3hp"
		$hitbox_mother.disabled = false
		health = 3
		add_to_group("player")
	else:
		assert(false, "invalid ship type")

func start(pos):
	position = pos

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

func take_damage(damage: int) -> void:
	if $InvulnerabilityTimer.is_stopped():
		health -= damage
		if health <= 0:
			queue_free()
		elif ship_type == ShipType.MOTHER:
			GameManager.flash()
			$InvulnerabilityTimer.start()
			$sprite.animation = "mothership-" + str(health) + "hp"
			$FlashingTimer.start()

func hit_scrap(scrap: Scrap):
	parent.add_scrap(scrap)

func _on_bullet_timer_timeout() -> void:
	if ship_type != ShipType.SHIELD:
		var bullet = bullet_scene.instantiate()
		bullet.position = position
		get_tree().get_root().add_child(bullet)
		bullet.set_bullet_type(Bullet.BulletType.PLAYER)


func _on_flashing_timer_timeout() -> void:
	self.visible = not self.visible


func _on_invulnerability_timer_timeout() -> void:
	$FlashingTimer.stop()
	self.visible = true
