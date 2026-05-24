class_name Bullet extends Area2D

# Cache node refs
@onready var bullet_small_hitbox: CollisionShape2D = $bullet_small_hitbox
@onready var bullet_large_hitbox: CollisionShape2D = $bullet_large_hitbox

var bullet_explosion_vfx : PackedScene = preload("res://scene/bullet_explosion.tscn")

var speed = 500
enum BulletType {PLAYER, ENEMY_1, ENEMY_2} #to be set on call by level
var bullet_type: BulletType 
var direction := Vector2.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bullet")
	bullet_large_hitbox.disabled=true
	bullet_small_hitbox.disabled=true
	$bullet_sprite.hide()
	# safety normalize
	direction = direction.normalized()
	# Assume sprites will point Vector2.RIGHT, right now
	# we have circles, so doesn't really matter
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	# Add delta to tie to physics frame
	position += speed * direction * delta

func set_bullet_type(new_type: BulletType) -> void:
	if new_type == BulletType.ENEMY_1:
		bullet_type = BulletType.ENEMY_1
		bullet_small_hitbox.disabled=false
		$bullet_sprite.play("enemy_1")
		$bullet_sprite.show()
		direction = Vector2.LEFT
		set_collision_mask_value(1, true)
		set_collision_mask_value(5, true)
		
	elif new_type == BulletType.ENEMY_2:
		bullet_type = BulletType.ENEMY_2
		bullet_large_hitbox.disabled=false
		$bullet_sprite.play("enemy_2")
		$bullet_sprite.show()
		direction = Vector2.LEFT
		set_collision_mask_value(1, true)
		set_collision_mask_value(5, true)
		
	else:
		bullet_type = BulletType.PLAYER
		bullet_small_hitbox.disabled=false
		$bullet_sprite.play("player")
		$bullet_sprite.show()
		direction = Vector2.RIGHT
		set_collision_mask_value(2, true)


func _on_area_entered(area: Area2D) -> void:
	# If the bullet colliders with anything on it's mask layer
	# that can take damage, clear damage to it
	if area.has_method("take_damage"):
		area.take_damage(1, self)
	elif area.is_in_group("boss"):
		area.get_parent().take_damage(1, self)
	
	# kill the bullet, on mask area hit
	var new_vfx = bullet_explosion_vfx.instantiate()
	new_vfx.position = position
	# TODO(tom) implement pooling
	get_parent().add_child(new_vfx)
	AudioManager.report_bullet_hit()
	queue_free()

# When bullets go out of view, delete them
func _on_screen_exited() -> void:
	queue_free()
