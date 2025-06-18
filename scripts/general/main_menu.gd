extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var team_node: Node3D = $DisplayNode
@onready var camera_a_start: float = 0
@onready var camera_a: float = camera_a_start
@onready var save_display_label = $Control/SaveSelect/Value

var spawn_particles = preload("res://particles/spawn_particles_world1.tscn")
var starting_game := false
var camera_returning := false
var save_ids := []
var save_id_n := 0

var saved_chums: Dictionary = {null: []}

func _ready() -> void:
	var dir = DirAccess.open("user://saves")
	#Go through all files in saves
	for i_pot in dir.get_files():
		#Only append if it is .tres and named an integer
		if i_pot.ends_with(".tres") and i_pot.get_slice(".", 0).is_valid_int():
			#Append to list
			var this_save:int = int(i_pot.get_slice(".", 0))
			save_ids.append(this_save)
			
			#Get saved chums for display purposed
			saved_chums[this_save] = []
			var saved_game:SavedGame = load("user://saves/%s.tres" % [this_save])
			for chum in saved_game.friendly_chums:
				saved_chums[this_save].append(chum["type"])

	save_ids.append(null)
	save_ids.sort()
	set_save_display()
	change_display_chums(false)
	
	
func change_display_chums(show_particles = false) -> void:
	var chum_list = saved_chums[save_ids[save_id_n]]
	var chum_count = len(chum_list)
	for node in team_node.get_node("chums").get_children():
		node.queue_free()
	
	var inc:int = 0
	for chum_str in chum_list:
		var chum_to_spawn = ChumsManager.get_specific_chum_str(chum_str)
		if chum_to_spawn:
			#Spawns chum
			var chum_instance = chum_to_spawn.instantiate()
			team_node.get_node("chums").add_child(chum_instance)
			var chum_position = team_node.global_position
			chum_position += Vector3(5.0 * sin(2*PI*inc/chum_count), 0, 5.0 * cos(2*PI*inc/chum_count))
			chum_instance.global_position = chum_position
			chum_instance.get_node("GeneralChumBehaviour").visible = false
			chum_instance.anim_player.play("Idle")
			chum_instance.sleep_zone.queue_free()
			chum_instance.scale = Vector3(2.0, 2.0, 2.0)
			chum_instance.rotation.y = randf_range(0, 2*PI)
			chum_instance.anim_player.speed_scale = randf_range(0.8, 1.2)
			#Spawn spawn particles:
			if show_particles and team_node.visible:
				chum_instance.particle_zone.add_child(spawn_particles.instantiate())
		inc += 1

func set_save_display() -> void:
	if save_ids[save_id_n] == null:
		save_display_label.text = "< New Reality (%s) >" % [get_smallest_missing_int(save_ids)]
	else:
		save_display_label.text = "< Reality %s >" % [save_ids[save_id_n]]

func _process(delta: float) -> void:
	camera_a += delta / 25
	
	if Input.is_action_just_pressed("cam_left") and not starting_game:
		camera_returning = true
		cycle_save_id(-1)
		set_save_display()
		change_display_chums(true)
		
	elif Input.is_action_just_pressed("cam_right") and not starting_game:
		camera_returning = true
		cycle_save_id(1)
		set_save_display()
		change_display_chums(true)

	if fmod(camera_a, 2 * PI) < 0.5:
		camera_returning = false
	
	if Input.is_action_just_pressed("attack") and not starting_game:
		starting_game = true
		TransitionScreen.transition(3)
		await TransitionScreen.on_transition_finished
		var savegame_id = save_ids[save_id_n]
		var is_new_game = true if savegame_id == null else false
		if savegame_id == null:
			savegame_id = get_smallest_missing_int(save_ids)
		Global.start_game(savegame_id, is_new_game)
		queue_free()

func _physics_process(delta: float) -> void:
	if camera_returning:
		camera_a += delta * 5

	camera.global_position = Vector3(15 * sin(camera_a), 10, 15 * cos(camera_a))
	camera.rotation.y = camera_a - (PI / 4)
	
func cycle_save_id(sign_) -> void:
	save_id_n += sign_
	if save_id_n + 1 > len(save_ids):
		save_id_n = 0
	elif save_id_n < 0:
		save_id_n = len(save_ids) - 1

func get_smallest_missing_int(list) -> int:
	var lowest = 1
	for n in list:
		if n == lowest:
			lowest += 1
		else:
			break
	return lowest
