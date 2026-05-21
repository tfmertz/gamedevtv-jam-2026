class_name ShipConnectionEdge extends Area2D

@onready var bullet_scene : PackedScene = preload("res://scene/bullet.tscn")

var source_ship : ShipNode = null
var dest_ship   : ShipNode = null
@export var ENEMY_Z  := 12
@export var PLAYER_Z := 11

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#TODO(isaac) idk why this isn't working so time to be lazy
	#z_index = Bullet.PLAYER_Z
	z_index = PLAYER_Z
	

func set_source_ship(ship: ShipNode):
	source_ship = ship


func set_dest_ship(ship: ShipNode):
	dest_ship = ship

func play_animation() -> void:
	$AnimatedSprite2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if source_ship != null and dest_ship != null:
		var angle = source_ship.position.angle_to_point(dest_ship.position)
		position = source_ship.position
		rotation = angle
		scale.x = source_ship.position.distance_to(dest_ship.position) / 64.0

func _physics_process(delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	# Don't do anything for matching areas
	# Connection only interacts with enemy ships/bullets
	if z_index == area.z_index:
		return
	# only hit things that can be damaged
	# TODO(isaac) we very likely want to scope bullet layers so enemy and player bullets don't
	# collider with eachother, or we might want that, IDK, leaving for now to ignore
	# see: tom's comment in bullet.gd
	if area.has_method("take_damage") and area.z_index == ENEMY_Z:
		area.take_damage(1)
