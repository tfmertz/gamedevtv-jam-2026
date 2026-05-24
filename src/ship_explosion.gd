extends Area2D

@export var color: Color = Color.WHITE
@export var radius := 80
@export var draw_shape := false
@export var damage := 0

@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	var initial_radius = radius
	# if our explosion is damaging add the white flash effect
	var tween := create_tween()
	tween.tween_property(self, "radius", 0, .3)
	# Start particles, TODO(tom) look into VFX pooling
	cpu_particles_2d.emitting = true
	cpu_particles_2d.finished.connect(queue_free)
	
	# wait a frame so we have physics info
	if damage > 0:
		draw_shape = true
		# wait a frame to set collision shape up, ready doesn't like it
		await get_tree().physics_frame
		collision_shape_2d.disabled = false
		collision_shape_2d.shape.radius = initial_radius
		# wait a frame for it to take and do explosion
		await get_tree().physics_frame
		_explode()
	
func _draw() -> void:
	if draw_shape:
		draw_circle(Vector2.ZERO, radius, color)

func _process(delta: float) -> void:
	if draw_shape:
		queue_redraw()

func _explode() -> void:
	var areas = get_overlapping_areas()
	for area in areas:
		if area.has_method("take_damage"):
			area.take_damage(damage, self)
