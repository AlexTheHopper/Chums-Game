extends Node3D
class_name BeingParticles
@onready var small_particles: CPUParticles3D = $SmallParticles
@onready var large_particles: CPUParticles3D = $LargeParticles

func restart_particles() -> void:
	small_particles.restart()
	large_particles.restart()
