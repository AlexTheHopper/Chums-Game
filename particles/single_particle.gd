extends Node3D

func _ready() -> void:
	$CPUParticles3D.emitting = true

func _on_cpu_particles_3d_finished() -> void:
	queue_free()
