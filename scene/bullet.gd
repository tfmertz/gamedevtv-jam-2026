extends Area2D

var speed = 10
enum type {PLAYER, ENEMY_1, ENEMY_2} #to be set on call by level
var bullet_type = type 
var bullet_direction = 1
var enemy_z =12
var player_z =11

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$despawn_timer.start()
	$bullet_large_hitbox.disabled=true
	$bullet_small_hitbox.disabled=true
	#$bullet_sprite.hide()
	rotation = PI/2

func _physics_process(delta: float) -> void:
	position += Vector2(sin(rotation),-cos(rotation)).normalized()*speed*bullet_direction
	
func _process(delta: float) -> void:
	pass

func _on_despawn_timer_timeout() -> void:
	queue_free()

func set_bullet_type(new_type) -> void:
	if new_type == "ENEMY_1":
		bullet_type = type.ENEMY_1
		$bullet_small_hitbox.disabled=false
		$bullet_sprite.play("enemy_1")
		$bullet_sprite.show()
		bullet_direction = -1
		z_index=enemy_z
		
	elif new_type == "ENEMY_2":
		bullet_type = type.ENEMY_2
		$bullet_large_hitbox.disabled=false
		$bullet_sprite.play("enemy_2")
		$bullet_sprite.show()
		bullet_direction = -1
		z_index=enemy_z
		
	else:
		bullet_type = type.PLAYER
		$bullet_small_hitbox.disabled=false
		$bullet_sprite.play("player")
		$bullet_sprite.show()
		bullet_direction = 1
		z_index=player_z
