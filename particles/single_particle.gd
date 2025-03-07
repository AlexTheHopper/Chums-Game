extends Node3D

signal completed

func _ready() -> void:
	$CPUParticles3D.emitting = true

func _on_cpu_particles_3d_finished() -> void:
	completed.emit()
	queue_free()
