extends Node

@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	# Start particles, TODO(tom) look into VFX pooling
	cpu_particles_2d.emitting = true
	cpu_particles_2d.finished.connect(queue_free)
