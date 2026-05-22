class_name ShipConnectionEdge extends Area2D

@onready var bullet_scene : PackedScene = preload("res://scene/bullet.tscn")

var source_ship : ShipNode = null
var dest_ship   : ShipNode = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

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
	# If connection hits an area on it's mask, and can deal
	# damage, then do it
	if area.has_method("take_damage"):
		area.take_damage(5)
