extends Area2D

signal die
var health: int
var health_gun = 1
var health_shield =2
var speed = 10
var target_direction: Vector2
var target_location: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$sprite.hide()
	$hitbox_gun.hide()
	$hitbox_shield.hide()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	flyto(target_location)

func spawn_shield() -> void: #spawns ship as shield ship, sets animation, health, hitbox
	$sprite.play("shield")
	$sprite.show()
	$hitbox_shield.show()
	health = health_shield

func spawn_gun() -> void: #spawns ship as gun ship, sets animation, health, hitbox
	$sprite.play("gun")
	$sprite.show()
	$hitbox_gun.show()
	health = health_gun

func flyto(location: Vector2) -> void:
	target_location = location
	target_direction = Vector2(target_location.x-position.x, target_location.y-position.y)
	var temp_speed = target_direction.length()/round(target_direction.length()/speed)
	if position != target_location:
		position = position+target_direction.normalized()*temp_speed
	

func _unhandled_input(event: InputEvent) -> void:  #placeholder for spawning ships
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_2:
			spawn_shield()
			#position=Vector2(100,100)
		elif event.pressed and event.keycode == KEY_1:
			spawn_gun()
			#position=Vector2(100,100)
		elif event.pressed and event.keycode == KEY_3:
			var randpoint = Vector2(randi() % 1120+32, randi() % 616+32)
			flyto(randpoint)
			print(randpoint)


func _on_area_entered(area: Area2D) -> void:
	if area.z_index==12:
		health=health-1
		if health==0:
			die.emit()
			queue_free()
