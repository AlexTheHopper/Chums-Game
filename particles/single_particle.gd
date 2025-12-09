extends Node3D
@onready var cpu_particles_3d: CPUParticles3D = $CPUParticles3D
@export var gradient: Gradient
signal completed

func _ready() -> void:
	cpu_particles_3d.mesh = cpu_particles_3d.mesh.duplicate()
	if gradient:
		cpu_particles_3d.color_ramp = gradient
	call_deferred("start_emitting") #So it can be moved if necessary

func start_emitting() -> void:
	cpu_particles_3d.emitting = true

func stop_emitting() -> void:
	cpu_particles_3d.emitting = false

func _on_cpu_particles_3d_finished() -> void:
	completed.emit()
	queue_free()
