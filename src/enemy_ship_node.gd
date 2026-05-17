extends Area2D

@export var bullet_scene: PackedScene =preload("res://scene/bullet.tscn")
signal die
signal fire
var health: int
var health_gun = 1
var health_shield =2
var health_enemy_small = 1
var health_enemy_big = 2
var speed_player = 10
var speed_enemy = 10
var speed =1 #placeholder speed
var target_direction: Vector2
var target_location: Vector2
enum type  {GUN, SHIELD, ENEMY_SMALL, ENEMY_BIG}
var ship_type = type
var player_z = 11
var enemy_z =12



func _ready() -> void:
	$sprite.hide()
	$hitbox_gun.hide()
	$hitbox_shield.hide()
	$hitbox_enemy_sm.hide()
	$hitbox_enemy_bg.hide()
	target_location=position
	
func _physics_process(delta: float) -> void:
	
	flyto(target_location)
	

func _process(delta: float) -> void:
	pass


func spawn_shield() -> void: #spawns ship as shield ship, sets animation, health, hitbox
	$sprite.play("shield")
	$sprite.show()
	$hitbox_shield.show()
	$bullet_timer.start()
	z_index=player_z
	speed = speed_player
	health = health_shield
	ship_type = type.SHIELD

func spawn_gun() -> void: #spawns ship as gun ship, sets animation, health, hitbox
	$sprite.play("gun")
	$sprite.show()
	$hitbox_gun.show()
	$bullet_timer.start()
	z_index=player_z
	speed = speed_player
	health = health_gun
	ship_type = type.GUN

func spawn_enemy_small() -> void: #spawns ship as gun ship, sets animation, health, hitbox
	$sprite.play("enemy_small")
	$sprite.show()
	$hitbox_enemy_sm.show()
	$bullet_timer.start()
	z_index=enemy_z
	speed = speed_enemy
	health = health_enemy_small
	ship_type = type.ENEMY_SMALL

func spawn_enemy_big() -> void: #spawns ship as gun ship, sets animation, health, hitbox
	$sprite.play("enemy_big")
	$sprite.show()
	$hitbox_enemy_bg.show()
	$bullet_timer.start()
	z_index=enemy_z
	speed = speed_enemy
	health = health_enemy_big
	ship_type = type.ENEMY_BIG

func flyto(location: Vector2) -> void: #recieves a target position as vector2
	target_location = location
	target_direction = Vector2(target_location.x-position.x, target_location.y-position.y)
	var temp_speed = target_direction.length()/round(target_direction.length()/speed) #sets a temporary speed equal to arrive at location exactly
	if position != target_location:
		position = position+target_direction.normalized()*temp_speed
	

func _unhandled_input(event: InputEvent) -> void:  #placeholder for spawning ships, to be removed/disabled
	if event is InputEventKey:#placeholder for spawning ships, to be removed/disabled
		if event.pressed and event.keycode == KEY_2:#placeholder for spawning ships, to be removed/disabled
			spawn_shield()#placeholder for spawning ships, to be removed/disabled
			print("key hit")
			#position=Vector2(100,100)#placeholder for spawning ships, to be removed/disabled
		elif event.pressed and event.keycode == KEY_1:#placeholder for spawning ships, to be removed/disabled
			spawn_gun()#placeholder for spawning ships, to be removed/disabled
			#position=Vector2(100,100)#placeholder for spawning ships, to be removed/disabled
		elif event.pressed and event.keycode == KEY_3:#placeholder for spawning ships, to be removed/disabled
			var randpoint = Vector2(randi() % 1120+32, randi() % 616+32)#placeholder for spawning ships, to be removed/disabled
			flyto(randpoint)#placeholder for spawning ships, to be removed/disabled
			#print(randpoint)#placeholder for spawning ships, to be removed/disabled
		elif event.pressed and event.keycode == KEY_4:#placeholder for spawning ships, to be removed/disabled
			spawn_enemy_small()#placeholder for spawning ships, to be removed/disabled
		elif event.pressed and event.keycode == KEY_5:#placeholder for spawning ships, to be removed/disabled
			spawn_enemy_big()#placeholder for spawning ships, to be removed/disabled


func _on_area_entered(area: Area2D) -> void:
	if area.z_index==12: #detecting if the body that entered it is an enemy
		health=health-1
		if health==0:
			die.emit(position, ship_type)
			queue_free()


func _on_timer_timeout() -> void:
	if ship_type!=type.SHIELD:
		var bullet = bullet_scene.instantiate()
		bullet.position = position 
		get_tree().get_root().add_child(bullet)
		
	
