extends Area2D

var speed = 20
enum type {PLAYER, ENEMY_1, ENEMY_2} #to be set on call by level
var bullet_type = type 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$despawn_timer.start()
	rotation = PI/2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if bullet_type==type.PLAYER:
		position += Vector2(sin(rotation),-cos(rotation)).normalized()*speed
	

func _on_despawn_timer_timeout() -> void:
	queue_free()
