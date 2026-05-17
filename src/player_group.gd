extends Node2D

# Cache references so we don't have to search node tree each frame
@onready var v_path_follow_2d: PathFollow2D = $VPath/VPathFollow2D
@onready var circle_path_follow_2d: PathFollow2D = $CirclePath/CirclePathFollow2D
@onready var diamond_path_follow_2d: PathFollow2D = $DiamondPath/DiamondPathFollow2D

var ship_scene : PackedScene = preload("res://scene/ship_node.tscn")

var velocity_dir = Vector2.ZERO
var velocity = Vector2.ZERO

var mothership
var ships: Array[ShipNode] = []

enum FormationType {V, CIRCLE, DIAMOND}
var formation = FormationType.V
var spacing = 1.0

var screen_size = get_viewport_rect()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect()


func spawn_mothership() -> void:
	mothership = ship_scene.instantiate()
	mothership.set_ship_type(ShipNode.ShipType.MOTHER)
	mothership.start(Vector2(screen_size.size.x / 2,screen_size.size.x / 2))
	add_child(mothership)


func add_gunship() -> void:
	var ship = ship_scene.instantiate()
	ship.set_ship_type(ShipNode.ShipType.GUN)
	ship.set_on_path()
	ship.start(Vector2(randi() % int(screen_size.size.x),randi() % int(screen_size.size.y))) #TODO VERY TEMPORARY
	ships.append(ship)
	add_child(ship)


func add_shieldship() -> void:
	var ship = ship_scene.instantiate()
	ship.set_ship_type(ShipNode.ShipType.SHIELD)
	ship.set_on_path()
	ship.start(Vector2(randi() % int(screen_size.size.x),randi() % int(screen_size.size.y))) #TODO VERY TEMPORARY
	ships.append(ship)
	add_child(ship)


func cycle_formation() -> void:
	pass


func cycle_spacing() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	velocity_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_just_pressed("cycle_formation"):
		formation = (formation + 1) % len(FormationType)
	elif Input.is_action_just_pressed("cycle_spacing"):
		spacing = (spacing + .5)
		if spacing > 1:
			spacing -= 1
		
	mothership.set_velocity_dir(velocity_dir)

	var new_path: PathFollow2D
	if formation == FormationType.V:
		new_path = v_path_follow_2d
	elif formation == FormationType.CIRCLE:
		new_path = circle_path_follow_2d
	elif formation == FormationType.DIAMOND:
		new_path = diamond_path_follow_2d
	for i in range(ships.size()):
		var ship := ships[i]
		ship.set_on_path()
		new_path.progress_ratio = (float(i) / float(ships.size())) * spacing
		ship.set_position_target(new_path.position + mothership.position)
		# set velo dir to mothership, we'll change if on_path = true in shipnode's physics process
		ship.set_velocity_dir(velocity_dir)
