extends State
class_name Chum25_Active
@onready var state_name := "Active"

@onready var chum: CharacterBody3D
var max_spawned_chums: int
var has_touched_floor := false
var spawned_chums := []
var spawn_particles := load("res://particles/spawn_particles_buzz.tscn")

func Enter():
	max_spawned_chums = min(5, 2 + floor(chum.quality["attack_damage"] / 5))
	chum.anim_player.speed_scale = 1.0 + (chum.quality["attack_speed"] / 10.0)
	chum.anim_player.play("Attack")
	has_touched_floor = false

func Physics_Update(delta: float):
	if chum.is_on_floor():
		chum.is_launched = false
		if not has_touched_floor:
			has_touched_floor = true
			chum.velocity = Vector3(0, 0, 0)
	else:
		has_touched_floor = false
		chum.velocity.y += chum.get_gravity_dir() * delta
	
	chum.move_and_slide()

func create_chum() -> void:
	if len(spawned_chums) >= max_spawned_chums:
		return

	var chum_to_add = ChumsManager.get_specific_chum_str("chum24")
	var chum_instance = chum_to_add.instantiate()
	
	chum_instance.quality = chum.quality
	chum_instance.bracelet_cost = 99 #This should never be relevant as it will disappear when parent chum leaves Active state.
	chum_instance.stats_set = true
	chum_instance.is_temporary = true

	chum_instance.initial_state_override = "Active"
	Global.current_room_node.get_parent().get_parent().get_node("Chums").add_child(chum_instance)
	#get_parent().add_child(chum_instance) #Used for the testing world.
	chum_instance.health_node.set_health(chum_instance.health_node.get_max_health())
	chum_instance.global_position = chum.global_position + Vector3(0.0, 1.2, 0.0)
	
	if chum.current_group == "Chums_Friend":
		chum_instance.make_friendly()
	else:
		chum_instance.make_enemy()
	chum_instance.health_node.immune = false
	spawned_chums.append(chum_instance)
	chum_instance.health_depleted.connect(free_spawn_room)
	
	chum.particle_zone.add_child(spawn_particles.instantiate())

func free_spawn_room() -> void:
	var new_spawned_chums := []
	for spawned_chum in spawned_chums:
		if spawned_chum.health_node.get_health() > 0:
			new_spawned_chums.append(spawned_chum)
	spawned_chums = new_spawned_chums

func remove_spawned_chums() -> void:
	for spawned_chum in spawned_chums:
		spawned_chum.health_node.health = 0

func Exit():
	chum.anim_player.speed_scale = 1.0
	chum.is_launched = false
	chum.hitbox.set_disabled(true)
	remove_spawned_chums()
