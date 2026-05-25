class_name ShipNode extends Area2D

@onready var bullet_scene : PackedScene = preload("res://scene/bullet.tscn")
@onready var scrap_scene : PackedScene = preload("res://scene/scrap.tscn")
@onready var death_particles: CPUParticles2D = $DeathParticles
@onready var mothership_death_particles: CPUParticles2D = $MothershipDeathParticles

enum ShipType {GUN, SHIELD, MOTHER}

var speed := 300
var terminal_speed := 500
var terminal_rotation := PI*randf_range(3.0,6.0)
var terminal_size := Vector2.ZERO
var ship_type: ShipType
var velocity := Vector2.ZERO
var velocity_dir := Vector2.ZERO
var terminal_velocity_dir := Vector2.ZERO
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
	if ship_type == ShipType.MOTHER:
		$CrashTimer.wait_time = 3.0
	else:
		$CrashTimer.wait_time = randf_range(0.75, 1.5)
	var last_size = randf_range(0.2, 0.8)
	terminal_size = Vector2(last_size, last_size)

func register_parent(new_parent) -> void:
	parent = new_parent


func set_velocity_dir(new_vel_dir) -> void:
	velocity_dir = new_vel_dir


func set_on_path() -> void:
	on_path = true


func set_off_path() -> void:
	on_path = false


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
		
	if terminal_velocity_dir != Vector2.ZERO:
		velocity_dir = terminal_velocity_dir
		speed = terminal_speed
		rotation += terminal_rotation * delta
		scale -= terminal_size * delta
	# Only move if velocity_dir is a meaningful number
	if not velocity_dir.is_zero_approx():
		# calculate ship velocity
		velocity = velocity_dir * speed
	else:
		# zero out velocity to make sure we're stopped
		velocity = Vector2.ZERO
	
	position += velocity * delta
	# for dying mother ships, bounce
	if mothership_death_particles.emitting:
		 # Bounce: flip velocity component on whichever axis went out of bounds
		if position.x <= 0 or position.x >= screen_size.size.x:
			terminal_velocity_dir.x = -terminal_velocity_dir.x
		if position.y <= 0 or position.y >= screen_size.size.y:
			terminal_velocity_dir.y = -terminal_velocity_dir.y
	position.x = clamp(position.x, 0, screen_size.size.x)
	position.y = clamp(position.y, 0, screen_size.size.y)

func take_damage(damage: int, source: Area2D) -> void:
	if $InvulnerabilityTimer.is_stopped():
		health -= damage
		if health <= 0:
			dramatic_death(source)
		elif ship_type == ShipType.MOTHER:
			GameManager.flash()
			$InvulnerabilityTimer.start()
			$sprite.animation = "mothership-" + str(health) + "hp"
			$FlashingTimer.start()
			if health == 1:
				AudioManager.report_player_very_injured()
			else:
				AudioManager.report_player_injured()


func dramatic_death(source: Area2D) -> void:
	if ship_type == ShipType.MOTHER:
		mothership_death_particles.emitting = true
	else:
		death_particles.emitting = true
	$CrashTimer.start()
	$HardDeathTimer.start()
	set_off_path()
	terminal_velocity_dir = source.position.direction_to(position)
	$bullet_timer.stop()
	$hitbox_gun.set_deferred("disabled", true)
	$hitbox_shield.set_deferred("disabled", true)

func hit_scrap(scrap: Scrap):
	parent.add_scrap(scrap)

func _on_bullet_timer_timeout() -> void:
	if GameManager.stop_player_control:
		return
	
	if ship_type != ShipType.SHIELD:
		var bullet = bullet_scene.instantiate()
		bullet.position = position
		get_tree().current_scene.add_child(bullet)
		bullet.set_bullet_type(Bullet.BulletType.PLAYER)


func _on_flashing_timer_timeout() -> void:
	self.visible = not self.visible


func _on_invulnerability_timer_timeout() -> void:
	$FlashingTimer.stop()
	self.visible = true


func _on_crash_timer_timeout() -> void:
	if is_instance_valid(self):
		queue_free()


func _on_hard_death_timer_timeout() -> void:
	if is_instance_valid(self):
		queue_free()
