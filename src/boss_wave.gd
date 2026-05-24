extends Node2D

var enemy_scene : PackedScene = preload("res://scene/enemy_ship_node.tscn")
var bomber_scene : PackedScene = preload("res://scene/bomber.tscn")
var bullet_scene : PackedScene = preload("res://scene/bullet.tscn")
var tommygun_scene: PackedScene = preload("res://src/tommy_gun.tscn")
@export var attack_spread := 10
@export var clip_size := 8
@export var attack_delay := .05
signal die
var ship_spawn_top = Vector2(1742,175)
var ship_spawn_bot = Vector2(1742,905)
var bullet_spawn_1 = Vector2(1736,26)
var bullet_spawn_2 = Vector2(1670,335)
var bullet_spawn_3 = Vector2(1670,745)
var bullet_spawn_4 = Vector2(1736,1054)
var health = 100
var target_location
var target_direction
var speed = 1
var tongueplaying = false
var wave = false
var attack_type = 1
@onready var boss_assets: Area2D = $boss_assets


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_location=Vector2(-300, position.y)
	$screen_enter_timer.start()
	$tongue_timer.stop()
	$ship_spawn_timer.stop()
	$bullet_timer.stop()
	$wave_timer.stop()
	#boss_assets.get_node("bossmid").play()
	boss_assets.get_node("bossmid").play("default")

func _physics_process(delta: float) -> void:
	flyto(target_location)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func flyto(location: Vector2) -> void: #recieves a target position as vector2
	target_location = location
	target_direction = Vector2(target_location.x-position.x, target_location.y-position.y)
	var temp_speed = target_direction.length()/round(target_direction.length()/speed) #sets a temporary speed equal to arrive at location exactly
	if position != target_location:
		position = position+target_direction.normalized()*temp_speed



func shoot_type1() -> void:
	
	var bullet1 = bullet_scene.instantiate()
	bullet1.position = bullet_spawn_1
	get_tree().get_root().add_child(bullet1)
	bullet1.set_bullet_type(Bullet.BulletType.ENEMY_2)
	
	var bullet2 = bullet_scene.instantiate()
	bullet2.position = bullet_spawn_2
	get_tree().get_root().add_child(bullet2)
	bullet2.set_bullet_type(Bullet.BulletType.ENEMY_2)
	
	var bullet3 = bullet_scene.instantiate()
	bullet3.position = bullet_spawn_3
	get_tree().get_root().add_child(bullet3)
	bullet3.set_bullet_type(Bullet.BulletType.ENEMY_2)
	
	var bullet4 = bullet_scene.instantiate()
	bullet4.position = bullet_spawn_4
	get_tree().get_root().add_child(bullet4)
	bullet4.set_bullet_type(Bullet.BulletType.ENEMY_2)
	
func shoot_type2() -> void:
	for i in range(clip_size):
		var bullet1 = bullet_scene.instantiate()
		bullet1.position = bullet_spawn_1
		get_tree().get_root().add_child(bullet1)
		bullet1.set_bullet_type(Bullet.BulletType.ENEMY_2)
		bullet1.direction = random_direction_around(Vector2.LEFT, attack_spread)
		
		var bullet2 = bullet_scene.instantiate()
		bullet2.position = bullet_spawn_2
		get_tree().get_root().add_child(bullet2)
		bullet2.set_bullet_type(Bullet.BulletType.ENEMY_2)
		bullet2.direction = random_direction_around(Vector2.LEFT, attack_spread)
		
		var bullet3 = bullet_scene.instantiate()
		bullet3.position = bullet_spawn_3
		get_tree().get_root().add_child(bullet3)
		bullet3.set_bullet_type(Bullet.BulletType.ENEMY_2)
		bullet3.direction = random_direction_around(Vector2.LEFT, attack_spread)
		
		var bullet4 = bullet_scene.instantiate()
		bullet4.position = bullet_spawn_4
		get_tree().get_root().add_child(bullet4)
		bullet4.set_bullet_type(Bullet.BulletType.ENEMY_2)
		bullet4.direction = random_direction_around(Vector2.LEFT, attack_spread)
		
		$attack_timer.wait_time = attack_delay
		$attack_timer.start()
		# wait "attack_deplay" for next bullet instantiation
		await $attack_timer.timeout


func _on_tongue_timer_timeout() -> void:
	
	if tongueplaying:
		boss_assets.get_node("tongue").hide()
		boss_assets.get_node("tongue").stop()
		$tongue_timer.wait_time = 2
		$tongue_timer.start()
		tongueplaying = false
	else:
		if (randi()%101 < 25): 
			boss_assets.get_node("tongue").show()
			boss_assets.get_node("tongue").play()
			$tongue_timer.wait_time = 1.2
			$tongue_timer.start()
			tongueplaying = true
	


func _on_screen_enter_timer_timeout() -> void:
	#start things
	$tongue_timer.start()
	$ship_spawn_timer.start()
	$screen_enter_timer.stop()
	#$bullet_timer.start()
	$wave_timer.start()


func _on_ship_spawn_timer_timeout() -> void:
	if (randi()%101 < 25): 
		spawn_ships()

func spawn_ships() -> void:
	if (randi()%101 < 50): 
		var ship = enemy_scene.instantiate()
		get_tree().get_root().add_child(ship)
		ship.spawn_enemy_big()
		ship.position = ship_spawn_top
		ship.set_rand_mode(true)
		
		var ship2 = enemy_scene.instantiate()
		get_tree().get_root().add_child(ship2)
		ship2.spawn_enemy_big()
		ship2.position = ship_spawn_bot
		ship2.set_rand_mode(true)
	else:
		var ship = bomber_scene.instantiate()
		ship.position = ship_spawn_top
		get_tree().get_root().add_child(ship)
		
		var ship2 = bomber_scene.instantiate()
		ship2.position = ship_spawn_bot
		get_tree().get_root().add_child(ship2)




func take_damage(damage: int, source: Area2D) -> void:
	health -= damage
	if health <= 0:
		die.emit()
		_die()


func _die() -> void:
	$tongue_timer.stop()
	$ship_spawn_timer.stop()
	$bullet_timer.stop()
	$wave_timer.stop()
	boss_assets.get_node("tongue").stop()
	boss_assets.get_node("tongue").hide()
	boss_assets.get_node("bossmid").play("death")
	flyto(Vector2(300, position.y))
	
	'''
func _unhandled_input(event: InputEvent) -> void:  #placeholder for spawning ships, to be removed/disabled
	if event is InputEventKey:#placeholder for spawning ships, to be removed/disabled
		if event.pressed and event.keycode == KEY_3:
			_die()
	'''


func _on_bullet_timer_timeout() -> void:
	if attack_type==2: 
		shoot_type2()
	else:
		shoot_type1()


func random_direction_around(base: Vector2, spread_degrees: float = 45.0) -> Vector2:
	var angle_offset = randf_range(-deg_to_rad(spread_degrees), deg_to_rad(spread_degrees))
	return base.normalized().rotated(angle_offset)


func _on_wave_timer_timeout() -> void:
	if wave:
		wave = false
		$wave_timer.wait_time =5
		$wave_timer.start()
		$bullet_timer.stop()
	else:
		wave = true
		if (randi()%101 < 25): 
			attack_type = 2
			$bullet_timer.wait_time = 1
			$bullet_timer.start()
			$wave_timer.wait_time =1
			$wave_timer.start()
		else:
			attack_type = 1
			$bullet_timer.wait_time = .1
			$bullet_timer.start()
			$wave_timer.wait_time =1
			$wave_timer.start()
