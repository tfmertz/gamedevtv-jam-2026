extends Node2D

var ship_scene : PackedScene = preload("res://scene/ship_node.tscn")

var velocity_dir = Vector2.ZERO
var velocity = Vector2.ZERO

var mothership
var ships = []

enum FormationType {V, CIRCLE, DIAMOND}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func spawn_mothership() -> void:
	mothership = ship_scene.instantiate()
	mothership.set_ship_type(ShipNode.ShipType.MOTHER)
	mothership.start(Vector2(0,0))
	add_child(mothership)


func add_gunship() -> void:
	var ship = ship_scene.instantiate()
	ship.set_ship_type(ShipNode.ShipType.GUN)
	ship.start(Vector2(0,74)) #TODO VERY TEMPORARY
	ships.append(ship)
	add_child(ship)


func add_shieldship() -> void:
	var ship = ship_scene.instantiate()
	ship.set_ship_type(ShipNode.ShipType.SHIELD)
	ship.start(Vector2(0,-74)) #TODO VERY TEMPORARY
	ships.append(ship)
	add_child(ship)


func cycle_formation() -> void:
	pass


func cycle_spacing() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("move_right"):
		velocity_dir.x = 1
		velocity_dir.y = 0
	elif Input.is_action_pressed("move_left"):
		velocity_dir.x = -1
		velocity_dir.y = 0
	elif Input.is_action_pressed("move_down"):
		velocity_dir.x = 0
		velocity_dir.y = 1
	elif Input.is_action_pressed("move_up"):
		velocity_dir.x = 0
		velocity_dir.y = -1
	else:
		velocity_dir.x = 0
		velocity_dir.y = 0
	
	if Input.is_action_pressed("cycle_formation"):
		pass
	elif Input.is_action_pressed("cycle_spacing"):
		pass
		
	mothership.set_velocity_dir(velocity_dir)
	for ship in ships:
		ship.set_velocity_dir(velocity_dir)
