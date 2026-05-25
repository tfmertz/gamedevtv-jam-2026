extends Node2D

# Cache references so we don't have to search node tree each frame
@onready var v_path_follow_2d: PathFollow2D = $VPath/VPathFollow2D
@onready var circle_path_follow_2d: PathFollow2D = $CirclePath/CirclePathFollow2D
@onready var diamond_path_follow_2d: PathFollow2D = $DiamondPath/DiamondPathFollow2D

var ship_scene : PackedScene = preload("res://scene/ship_node.tscn")
var scrap_scene : PackedScene = preload("res://scene/scrap.tscn")
var ship_conn_scene : PackedScene = preload("res://scene/ship_connection_edge.tscn")

var velocity_dir = Vector2.ZERO
var velocity = Vector2.ZERO

var mothership: ShipNode
var ships: Array[ShipNode] = []
var connections = [] #: Array[ShipConnectionEdge] = []

enum FormationType {V, CIRCLE, DIAMOND}
enum ShipOrderType {INTERLACE, SHIELD_FIRST, GUN_FIRST}
var formation = FormationType.V
var ship_order = -1
var spacing = 1.0
var can_sprint = true

var screen_size: Rect2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var NUM_CIRCLE_POINTS = 20
	var RADIUS = 250
	var path_curve = Curve2D.new()
	for i in range(NUM_CIRCLE_POINTS):
		var angle = ((float(i) / NUM_CIRCLE_POINTS) * TAU) - (TAU/4)
		var pos = Vector2(cos(angle), sin(angle)) * RADIUS
		path_curve.add_point(pos)
	var last_angle = -TAU/4
	path_curve.add_point(Vector2(cos(last_angle), sin(last_angle)) * RADIUS)
		
	$CirclePath.set_curve(path_curve)
	screen_size = get_viewport_rect()


func spawn_mothership() -> void:
	mothership = ship_scene.instantiate()
	mothership.register_parent(self)
	mothership.set_ship_type(ShipNode.ShipType.MOTHER)
	mothership.start(Vector2(screen_size.size.x / 4,screen_size.size.y / 2))
	add_child(mothership)

#TODO ew
func add_gunship(spawn:Vector2 = Vector2(randi() % int(screen_size.size.x),randi() % int(screen_size.size.y))) -> void:
	var ship = ship_scene.instantiate()
	ship.register_parent(self)
	ship.set_ship_type(ShipNode.ShipType.GUN)
	ship.set_on_path()
	ship.start(spawn)
	ships.append(ship)
	call_deferred("add_child", ship)
	add_single_connection(ship)

#TODO also ew
func add_shieldship(spawn:Vector2 = Vector2(randi() % int(screen_size.size.x),randi() % int(screen_size.size.y))) -> void:
	var ship = ship_scene.instantiate()
	ship.register_parent(self)
	ship.set_ship_type(ShipNode.ShipType.SHIELD)
	ship.set_on_path()
	ship.start(spawn)
	ships.append(ship)
	call_deferred("add_child", ship)
	add_single_connection(ship)


func add_single_connection(new_ship: ShipNode) -> void:
	if ships.size() > 1 and is_instance_valid(ships[-2]) and is_instance_valid(new_ship):
		var connection = ship_conn_scene.instantiate()
		connection.set_source_ship(ships[-2])
		connection.set_dest_ship(new_ship)
		connection.play_animation()
		connections.append(connection)
		call_deferred("add_child", connection)
	if (ships.size() > 2 and (formation == FormationType.CIRCLE or formation == FormationType.DIAMOND) 
		and spacing >= 1 and is_instance_valid(ships[-1]) and is_instance_valid(ships[0])):
		#remove -2 because we just added a new connection between the second to last ship and this one,
		#so trim the connection between second to last and first, then add one between newest and first
		if ships.size() > 3:
			connections[-2].remove_from_group("connections")
			connections[-2].queue_free()
			connections.remove_at(-2)
		var connection2 = ship_conn_scene.instantiate()
		connection2.set_source_ship(ships[-1])
		connection2.set_dest_ship(ships[0])
		connection2.play_animation()
		connections.append(connection2)
		call_deferred("add_child", connection2)

func add_scrap(scrap: Scrap):
	if scrap.scrap_type == scrap.ScrapType.SHIELD:
		add_shieldship(scrap.position)
	elif scrap.scrap_type == scrap.ScrapType.GUN:
		add_gunship(scrap.position)


func cycle_formation() -> void:
	pass


func cycle_spacing() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var check_last_connection = false
	var close_loop            = false
	var toggle_ship_grouping  = false
	
	if not GameManager.stop_player_control:
		velocity_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	else:
		velocity_dir = Vector2.ZERO
	
	if Input.is_action_just_pressed("cycle_formation"):
		formation = (formation + 1) % len(FormationType)
		toggle_ship_grouping = true
	elif Input.is_action_just_pressed("cycle_spacing"):
		spacing = (spacing + .5)
		if spacing > 1:
			spacing -= 1
		toggle_ship_grouping = true
	elif Input.is_action_just_pressed("sort_ships"):
		ship_order = (ship_order + 1) % len(ShipOrderType)
		toggle_ship_grouping = true
	elif Input.is_action_just_pressed("sprint"):
		if can_sprint:
			$SprintTimer.start()
			can_sprint = false
			mothership.start_sprinting()
	
	if mothership:
		mothership.set_velocity_dir(velocity_dir)
	else:
		# handle game over
		GameManager.load_scene("res://scene/ui/game_over.tscn")
		return

	var new_path: PathFollow2D
	var path_offset = 0
	if formation == FormationType.V:
		new_path = v_path_follow_2d
		if spacing < 1:
			path_offset = 0.25
	elif formation == FormationType.CIRCLE:
		new_path = circle_path_follow_2d
		close_loop = true
	elif formation == FormationType.DIAMOND:
		new_path = diamond_path_follow_2d
		close_loop = true
		
	var deleted_ship_idx: Array[int] = []
	for i in range(ships.size()):
		var ship := ships[i]
		var gap_size = 0.0
		var gap_offset = 0.0
		if ships.size() >= 2:
			gap_size = 100.0 / ships.size()
			gap_offset = (gap_size / (ships.size() - 1)) / 100.0
		
		# If ship was destroyed, remove it
		# TODO(tom) we could use signals for this, but this handles
		# a hard check if ship is ever null
		if not ship:
			deleted_ship_idx.push_front(i)
			continue
		
		if formation == FormationType.V:
			new_path.progress_ratio = (((float(i) / float(ships.size())) + (float(i) * gap_offset)) * spacing) + path_offset
		else:
			new_path.progress_ratio = ((float(i) / float(ships.size())) * spacing) + path_offset
		ship.set_position_target(new_path.position + mothership.position)
		# set velo dir to mothership, we'll change if on_path = true in shipnode's physics process
		ship.set_velocity_dir(velocity_dir)
	
	
	if deleted_ship_idx.size() > 0 or toggle_ship_grouping:
		for connection in connections:
			connection.remove_from_group("connections")
			connection.queue_free()
		connections.clear()
	
	# remove deleted ships from array
	for i in deleted_ship_idx:
		ships.remove_at(i)
	
	if toggle_ship_grouping:
		if ship_order == ShipOrderType.INTERLACE:
			interlace_ships()
		elif ship_order == ShipOrderType.SHIELD_FIRST:
			ships.sort_custom(func(a,b): return a.ship_type < b.ship_type)
		elif ship_order == ShipOrderType.GUN_FIRST:
			ships.sort_custom(func(a,b): return a.ship_type > b.ship_type)
	
	if deleted_ship_idx.size() > 0 or toggle_ship_grouping:
		recalculate_connections()
	
func recalculate_connections() -> void:
	assert(connections.size() == 0)
	var prev_ship = null
	for ship in ships:
		if prev_ship != null and ship != null:
			var connection = ship_conn_scene.instantiate()
			connection.set_source_ship(prev_ship)
			connection.set_dest_ship(ship)
			connection.play_animation()
			connections.append(connection)
			call_deferred("add_child", connection)
			
		if ship != null:
			prev_ship = ship
	if ships.size() > 2 and (formation == FormationType.CIRCLE or formation == FormationType.DIAMOND) and spacing >= 1:
		var connection = ship_conn_scene.instantiate()
		connection.set_source_ship(ships[-1])
		connection.set_dest_ship(ships[0])
		connection.play_animation()
		connections.append(connection)
		call_deferred("add_child", connection)

func interlace_ships() -> void:
	var gun_ships    = ships.filter(func(item): return item.ship_type == ShipNode.ShipType.GUN)
	var shield_ships = ships.filter(func(item): return item.ship_type == ShipNode.ShipType.SHIELD)
	var new_ships: Array[ShipNode] = []
	while(gun_ships.size() > 0 or shield_ships.size() > 0):
		if gun_ships.size() > 0:
			new_ships.append(gun_ships.pop_back())
		if shield_ships.size() > 0:
			new_ships.append(shield_ships.pop_back())
	ships = new_ships
	

func notify_can_sprint() -> void:
	$SprintTimer.stop()
	can_sprint = true
	mothership.can_sprint()
	


func _on_sprint_timer_timeout() -> void:
	can_sprint = true
	mothership.can_sprint()
