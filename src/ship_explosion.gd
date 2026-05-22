extends Node2D

@export var color: Color = Color.WHITE
@export var radius := 80

@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(self, "radius", 0.5, .5)
	# Start particles, TODO(tom) look into VFX pooling
	cpu_particles_2d.emitting = true
	cpu_particles_2d.finished.connect(queue_free)
	
func _draw() -> void:
	draw_circle(position, radius, color)

func _process(delta: float) -> void:
	queue_redraw()
