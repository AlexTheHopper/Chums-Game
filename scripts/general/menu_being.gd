extends CharacterBody3D

@onready var target_pos := Vector3(11.0, 5.0, 0.0)
var spawn_particles = preload("res://particles/spawn_particles_world1.tscn")
var spawn_count := 25
var spawned_player := false
var lerp_speed := 2.5
@onready var display_node := get_parent().get_node("DisplayNode")

func set_new_target():
	var tar_pos = get_parent().get_node("Camera3D/Target").global_position
	var x = max(min(tar_pos.x + randf_range(-20, 20), 25.0), -25.0)
	var y = tar_pos.y + randf_range(-5, 2.5)
	var z = max(min(tar_pos.z + randf_range(-20, 20), 25.0), -25.0)
	
	target_pos = Vector3(x, y, z)
	
	if spawned_player:
		spawn_chum()
	else:
		spawned_player = true
		lerp_speed = 1.0
		display_node.visible = true
		display_node.get_node("player/AnimationPlayer").play("Idle_noCarry")
		#display_node.add_child(spawn_particles.instantiate())
		for node in display_node.get_node("chums").get_children():
			print(node)
			node.add_child(spawn_particles.instantiate())

func spawn_chum():
	if $RayCast3D.is_colliding() and spawn_count > 0 and Functions.distance_squared(self, display_node) > 75.0:
		var chum_to_spawn = ChumsManager.get_world_random_chum(10.0, 1)["object"]
		if chum_to_spawn:
			#Spawns chum
			var chum_instance = chum_to_spawn.instantiate()
			get_parent().get_node("Chums").add_child(chum_instance)
			chum_instance.global_position = $RayCast3D.get_collision_point()
			chum_instance.get_node("GeneralChumBehaviour").visible = false
			#Spawn spawn particles:
			chum_instance.particle_zone.add_child(spawn_particles.instantiate())
			print('1')
			
			spawn_count -= 1
			
	elif spawn_count <= 0:
		$SmallParticles.emitting = false
		$LargeParticles.emitting = false

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, target_pos, 0.2 * delta * lerp_speed)
	if (global_position - target_pos).length() < 1.0:
		set_new_target()
