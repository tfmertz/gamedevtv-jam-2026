class_name Bullet extends Area2D


# Cache node refs
@onready var bullet_small_hitbox: CollisionShape2D = $bullet_small_hitbox
@onready var bullet_large_hitbox: CollisionShape2D = $bullet_large_hitbox


var speed = 500
enum BulletType {PLAYER, ENEMY_1, ENEMY_2} #to be set on call by level
var bullet_type: BulletType 
var direction := Vector2.RIGHT

@export var ENEMY_Z  := 12
@export var PLAYER_Z := 11

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bullet_large_hitbox.disabled=true
	bullet_small_hitbox.disabled=true
	#$bullet_sprite.hide()
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
		z_index=ENEMY_Z
		
	elif new_type == BulletType.ENEMY_2:
		bullet_type = BulletType.ENEMY_2
		bullet_large_hitbox.disabled=false
		$bullet_sprite.play("enemy_2")
		$bullet_sprite.show()
		direction = Vector2.LEFT
		z_index=ENEMY_Z
		
	else:
		bullet_type = BulletType.PLAYER
		bullet_small_hitbox.disabled=false
		$bullet_sprite.play("player")
		$bullet_sprite.show()
		direction = Vector2.RIGHT
		z_index=PLAYER_Z


func _on_area_entered(area: Area2D) -> void:
	# Don't do anything for matching areas
	# Bullet will kill itself of any area that doesn't match its z_index
	if z_index == area.z_index or (area is Enemy and z_index == ENEMY_Z):
		return
	# only hit things that can be damaged
	# TODO(tom) we might want to scope bullet layers so enemy and player bullets don't
	# collider with eachother, or we might want that, IDK, leaving for now to ignore
	if area.has_method("take_damage"):
		# If I'm an enemy bullet and hitting player ship
		if z_index == ENEMY_Z and area.z_index == PLAYER_Z:
			area.take_damage(1)
		# otherwise if I"m a player bullet and hit an enemy ship
		elif z_index == PLAYER_Z and area.z_index == ENEMY_Z:
			area.take_damage(1)
	
	# kill the bullet
	#TODO(tom) spawn VFX
	AudioManager.report_bullet_hit()
	queue_free()

# When bullets go out of view, delete them
func _on_screen_exited() -> void:
	queue_free()
