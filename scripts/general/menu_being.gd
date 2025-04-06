extends CharacterBody3D

@onready var target_pos := Vector3(14.0, 5.0, 4.0)
var spawn_particles = preload("res://particles/spawn_particles_world1.tscn")
var spawn_count := 25

func set_new_target():
	var tar_pos = get_parent().get_node("Camera3D/Target").global_position
	var x = max(min(tar_pos.x + randf_range(-20, 20), 25.0), -25.0)
	var y = tar_pos.y + randf_range(-5, 2.5)
	var z = max(min(tar_pos.z + randf_range(-20, 20), 25.0), -25.0)
	
	target_pos = Vector3(x, y, z)
	
	spawn_chum()

func spawn_chum():
	if $RayCast3D.is_colliding() and spawn_count > 0:		
		var chum_to_spawn = ChumsManager.get_random_world1_chum(1.0)["object"]
		if chum_to_spawn:
			#Spawns chum
			var chum_instance = chum_to_spawn.instantiate()
			get_parent().get_node("Chums").add_child(chum_instance)
			chum_instance.global_position = $RayCast3D.get_collision_point()
			#Spawn spawn particles:
			chum_instance.particle_zone.add_child(spawn_particles.instantiate())
			
			spawn_count -= 1
			
	elif spawn_count <= 0:
		$SmallParticles.emitting = false
		$LargeParticles.emitting = false

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, target_pos, 0.2 * delta)
	if (global_position - target_pos).length() < 0.5:
		set_new_target()
