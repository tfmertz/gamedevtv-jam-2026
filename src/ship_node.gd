class_name ShipNode extends Area2D

enum ShipType {GUN, SHIELD, MOTHER}
var velocity = Vector2.ZERO
var velocity_dir = Vector2.ZERO
var ship_type
var hp

var speed = 400

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_velocity_dir(new_vel_dir) -> void:
	velocity_dir = new_vel_dir


func set_ship_type(new_type) -> void:
	ship_type = new_type
	if ship_type == ShipType.GUN:
		$sprite.animation = "gun"
		hp = 1
	elif ship_type == ShipType.SHIELD:
		$sprite.animation = "shield"
		hp = 1
	elif ship_type == ShipType.MOTHER:
		$sprite.animation = "mothership-3hp"
		hp = 3
	else:
		assert(false, "invalid ship type")


func start(pos):
	position = pos
	show()
	if ship_type == ShipType.GUN:
		$hitbox_gun.disabled = false
	elif ship_type == ShipType.SHIELD:
		$hitbox_shield.disabled = false
	elif ship_type == ShipType.MOTHER:
		$hitbox_mother.disabled = false
	else:
		assert(false, "invalid ship type")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if velocity_dir.length() > 0:
		velocity = velocity_dir * speed
	else:
		velocity = Vector2.ZERO
	position += velocity * delta
