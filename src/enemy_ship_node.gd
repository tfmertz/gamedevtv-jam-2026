extends Enemy

@onready var bullet_scene : PackedScene = preload("res://scene/bullet.tscn")
@onready var scrap_scene : PackedScene = preload("res://scene/scrap.tscn")
@onready var hitbox_enemy_bg: CollisionShape2D = $hitbox_enemy_bg
@onready var hitbox_enemy_sm: CollisionShape2D = $hitbox_enemy_sm

signal die
signal fire

@export var ship_type: EnemyType = EnemyType.NONE
@export var rand_mode := false

var health_enemy_small = 1
var health_enemy_big = 2
var target_location: Vector2
enum EnemyType {NONE, ENEMY_SMALL, ENEMY_BIG}
var wind_x: int
var wind_y: int
var rand_coutner = 3
var sector_counter = 2
var sprite_half = 32


func _ready() -> void:
	wind_x = get_viewport_rect().size.x
	wind_y = get_viewport_rect().size.y
	#$sprite.hide()
	hitbox_enemy_sm.disabled = true
	hitbox_enemy_bg.disabled = true
	$rand_timer.stop()
	target_location = Vector2(-50, position.y)
	#$ExplosionArea/hitbox_collision_explosion.disabled = true
	if ship_type == EnemyType.ENEMY_SMALL:
		spawn_enemy_small()
	elif ship_type == EnemyType.ENEMY_BIG:
		spawn_enemy_big()
	
	if rand_mode:
		set_rand_mode(true)

func _physics_process(delta: float) -> void:
	flyto(delta)

func _process(delta: float) -> void:
	pass


func scrap_chance_calculator(fleet_size: int) -> float:
	var chance = 0.55
	if fleet_size < 6:
		chance = 1
	else:
		chance -= fleet_size * 0.01
	return chance

func take_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		die.emit(position, ship_type)
		#TODO(isaac) i suspect this is bad to do, but it's saturday so whatever
		var player_fleet_size = get_node("/root/Level").player_fleet.ships.size()
		var scrap_chance = scrap_chance_calculator(player_fleet_size)
		if randf_range(0, 1) < scrap_chance:
			var scrap = scrap_scene.instantiate()
			scrap.position = position
			get_tree().get_root().call_deferred("add_child", scrap)
			#scrap.call_deferred("set_movement")
		# don't explode for damage on bullet kills
		_die()

func spawn_enemy_small() -> void: #spawns ship as gun ship, sets animation, health, hitbox
	$sprite.play("enemy_alt")
	$sprite.show()
	#hitbox_enemy_sm.disabled = false
	hitbox_enemy_bg.disabled = false
	$bullet_timer.start()
	health = health_enemy_small
	ship_type = EnemyType.ENEMY_SMALL

func spawn_enemy_big() -> void: #spawns ship as gun ship, sets animation, health, hitbox
	$sprite.play("enemy_big")
	$sprite.show()

	hitbox_enemy_bg.disabled = false
	$bullet_timer.start()
	health = health_enemy_big
	ship_type = EnemyType.ENEMY_BIG

func flyto(delta: float) -> void: #recieves a target position as vector2
	var dir = position.direction_to(target_location)
	# sets a temporary speed equal to arrive at location exactly
	if position.distance_to(target_location) > 5:
		position += dir * speed * delta


func _unhandled_input(event: InputEvent) -> void:  #placeholder for spawning ships, to be removed/disabled
	if event is InputEventKey:#placeholder for spawning ships, to be removed/disabled
		"""if event.pressed and event.keycode == KEY_3:#placeholder for spawning ships, to be removed/disabled
			var randpoint = Vector2(randi() % 1120+32, randi() % 616+32)#placeholder for spawning ships, to be removed/disabled
			flyto(randpoint)#placeholder for spawning ships, to be removed/disabled
			#print(randpoint)#placeholder for spawning ships, to be removed/disabled
		elif event.pressed and event.keycode == KEY_4:#placeholder for spawning ships, to be removed/disabled
			spawn_enemy_small()#placeholder for spawning ships, to be removed/disabled
		elif event.pressed and event.keycode == KEY_5:#placeholder for spawning ships, to be removed/disabled
			spawn_enemy_big()
		elif event.pressed and event.keycode == KEY_6:#placeholder for spawning ships, to be removed/disabled
			set_rand_mode(true)#placeholder for spawning ships, to be removed/disabled"""
	pass

func _on_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	
	get_tree().get_root().add_child(bullet)
	
	#if ship_type == EnemyType.ENEMY_SMALL:
		#bullet.set_bullet_type(Bullet.BulletType.ENEMY_1)
	#elif ship_type == EnemyType.ENEMY_BIG:
	bullet.set_bullet_type(Bullet.BulletType.ENEMY_2)
		
	

func set_rand_mode(mode: bool) -> void:
	if mode:
		rand_mode = true
		$rand_timer.start()
		#position = Vector2(wind_x+sprite_half,randi_range(sprite_half,wind_y-sprite_half))
		var randpoint = Vector2(randi_range((wind_x*sector_counter/3+sprite_half),wind_x-sprite_half-wind_x/5), randi_range(sprite_half,wind_y-sprite_half))#placeholder for spawning ships, to be removed/disabled
		target_location = randpoint
	else:
		rand_mode = false
		$rand_timer.stop()

func _on_rand_timer_timeout() -> void:
	if rand_mode:
		rand_coutner=rand_coutner-1
		if rand_coutner == 0:
			sector_counter = sector_counter-1
			rand_coutner=3
		if sector_counter == -1:
			rand_coutner=0
		if sector_counter == -2:
			queue_free()
		target_location = Vector2(randi_range((wind_x*sector_counter/3+sprite_half),wind_x*(sector_counter+1)/3-sprite_half-wind_x/5), randi_range(sprite_half,wind_y-sprite_half))
