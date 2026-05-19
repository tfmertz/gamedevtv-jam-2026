class_name Scrap extends Area2D

enum ScrapType {SHIELD, GUN}

var screen_size: Rect2
var PATH_SAMPLES := 200
var AMPLITUDE_RATIO := 10
var frequency_ratio: float
var amplitude: int
var frequency: float
var speed = 200
var spawn_position: Vector2
var scrap_type: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scrap_type = randi_range(0, ScrapType.size())
	if scrap_type == ScrapType.SHIELD:
		$scrap_sprite.animation = "shield"
	else:
		$scrap_sprite.animation = "gun"
	

func set_movement() -> void:
	#TODO Isaac: i think the origin is wrong here because
	#of weird Y movement initially, but it mostly behaves
	spawn_position = position
	screen_size = get_viewport_rect()
	amplitude = int(screen_size.size.y / AMPLITUDE_RATIO)
	frequency_ratio = randf_range(4.0, 64.0)
	frequency = frequency_ratio / screen_size.size.x
	var path_curve = Curve2D.new()
	for i in range(PATH_SAMPLES):
		var pos: Vector2
		if i == 0:
			pos = position
		else:
			var x = position.x - (position.x*(float(i)/PATH_SAMPLES))
			pos = Vector2(x, position.y - (amplitude * sin(frequency * x)))
		path_curve.add_point(pos)
		
	$MovementPath2D.set_curve(path_curve)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$MovementPath2D/MovementPathFollow2D.progress += delta * speed
	self.position = $MovementPath2D/MovementPathFollow2D.position# + spawn_position


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("hit_scrap"):
		area.hit_scrap(self)
		queue_free()
