extends Node2D

var bullet_scene: PackedScene = preload("res://scene/bullet.tscn")
var enemy_scene: PackedScene = preload("res://scene/enemy_ship_node.tscn")
var ship_scene: PackedScene = preload("res://scene/ship_node.tscn")
var group_scene : PackedScene = preload("res://scene/player_group.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set up the ship and bullet
	_spawn_bullet()
	_spawn_enemy()
	_spawn_mothership(Vector2(500, 500))
	
	for i in range(5):
		var pos = Vector2(400, 450 + i * 20)
		_spawn_ship(pos)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _spawn_bullet():
	var new_bullet : Bullet = bullet_scene.instantiate()
	new_bullet.position = Vector2(100, 100)
	add_child(new_bullet)
	new_bullet.set_bullet_type(Bullet.BulletType.PLAYER)

func _spawn_enemy():
	var new_enemy = enemy_scene.instantiate()
	new_enemy.position = Vector2(400, 100)
	add_child(new_enemy)
	new_enemy.spawn_enemy_big()

func _spawn_ship(pos: Vector2):
	var new_ship = ship_scene.instantiate()
	add_child(new_ship)
	new_ship.set_ship_type(ShipNode.ShipType.SHIELD)
	new_ship.start(pos)
	
func _spawn_mothership(pos: Vector2):
	var player_fleet = group_scene.instantiate()
	add_child(player_fleet)
	player_fleet.spawn_mothership()

func _on_timer_timeout() -> void:
	_spawn_bullet()
