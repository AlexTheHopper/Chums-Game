extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var team_node: Node3D = $DisplayNode
@onready var camera_a_start: float = 0
@onready var camera_a: float = camera_a_start

@export var groups: Dictionary[int, ButtonsGroup]
@export var start_button: MenuInteract
@export var tutorial_button: MenuInteract
@export var settings_button: MenuInteract
@export var quit_button: MenuInteract

@export var fullscreen_button: MenuInteract
@export var camerashake_button: MenuInteract
@export var language_button: MenuInteract
@export var volumemusic_button: MenuInteract
@export var volumesfx_button: MenuInteract
@export var return_button: MenuInteract

@export var current_group : ButtonsGroup
var current_group_index := 0

var spawn_particles = preload("res://particles/spawn_particles_world1.tscn")
var bonus_chum_particles = preload("res://particles/bonus_chum_particles.tscn")
var transitioning := false
var camera_returning := false
var save_nums := []
var existing_save_nums := []

var saved_chums: Dictionary = {null: []}

func _ready() -> void:
	for group in groups.values():
		group.visible = false
	groups[0].visible = true
	current_group.buttons[current_group_index].on_selected()

	#Group 0 - Main Menu
	start_button.start_game.connect(on_start_game)
	start_button.save_changed.connect(change_display_chums)
	tutorial_button.start_tutorial.connect(on_start_tutorial)
	settings_button.move_to_menu.connect(change_buttons_group)
	quit_button.quit_game.connect(on_quit_game)
	#Group 1 - Settings Menu
	language_button.select_language.connect(update_language)
	return_button.move_to_menu.connect(change_buttons_group)
	

	var dir = DirAccess.open("user://saves")
	#Go through all files in saves
	for i_pot in dir.get_files():
		#Only append if it is .tres and named an integer
		if i_pot.ends_with(".tres") and i_pot.get_slice(".", 0).is_valid_int():
			#Append to list
			var this_save:int = int(i_pot.get_slice(".", 0))
			save_nums.append(this_save)
			existing_save_nums.append(this_save)
			
			#Get saved chums for display purposed
			saved_chums[this_save] = []
			var saved_game: SavedGame = load("user://saves/%s.tres" % [this_save])
			for chum in saved_game.friendly_chums:
				saved_chums[this_save].append(chum["id"])

	for bonus_id in SaverLoader.game_stats["bonus_chums"].keys():
		if bonus_id not in save_nums:
			save_nums.append(bonus_id)
	save_nums.sort()
	save_nums.append(null) #Option for a new game
	#Tell the start button which are just a bonus chum and which are existing saves.
	start_button.existing_save_nums = existing_save_nums
	start_button.save_nums = save_nums
	change_display_chums(save_nums[0])

	AudioManager.create_music(SoundMusic.SOUND_MUSIC_TYPE.MENU)

func _process(delta: float) -> void:
	camera_a += delta / 25
	if fmod(camera_a, 2 * PI) < 0.5:
		camera_returning = false
	if transitioning:
		return
	
	if Input.is_action_just_pressed("cam_left") or Input.is_action_just_pressed("move_left"):
		current_group.buttons[current_group_index].left()
		
	elif Input.is_action_just_pressed("cam_right") or Input.is_action_just_pressed("move_right"):
		current_group.buttons[current_group_index].right()
	
	elif Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("attack"):
		current_group.buttons[current_group_index].interact()
	
	elif Input.is_action_just_pressed("move_forward") or Input.is_action_just_pressed("cam_up"):
		current_group.buttons[current_group_index].on_deselected()
		current_group_index -= 1
		if current_group_index < 0:
			current_group_index = current_group.buttons.size() - 1
		current_group.buttons[current_group_index].on_selected()
		
	elif Input.is_action_just_pressed("move_back") or Input.is_action_just_pressed("cam_down"):
		current_group.buttons[current_group_index].on_deselected()
		current_group_index += 1
		if current_group_index > current_group.buttons.size() - 1:
			current_group_index = 0
		current_group.buttons[current_group_index].on_selected()

func _physics_process(delta: float) -> void:
	if camera_returning:
		camera_a += delta * 5

	camera.global_position = Vector3(15 * sin(camera_a), 10, 15 * cos(camera_a))
	camera.rotation.y = camera_a - (PI / 4)

func change_buttons_group(new_group_int: int) -> void:
	if new_group_int not in groups.keys():
		return
	current_group.buttons[current_group_index].on_deselected()
	var time := 1.0
	var incoming_pos := Vector2(250.0, 0.0)
	var target_pos := Vector2(0.0, 0.0)
	var outgoing_pos := Vector2(0.0, 500.0)
	transitioning = true
	groups[new_group_int].visible = true
	
	#Outgoing menu:
	get_tree().create_tween().tween_property(current_group, "position", outgoing_pos, time)
	#Incoming menu:
	groups[new_group_int].position = incoming_pos
	var incoming_tween := get_tree().create_tween().tween_property(groups[new_group_int], "position", target_pos, time)
	
	await incoming_tween.finished

	current_group.visible = false
	current_group_index = 0
	current_group = groups[new_group_int]
	current_group.buttons[current_group_index].on_selected()
	transitioning = false

#This is needed as the save file string is a composit string and is not automatically translated.
func update_language(_lan_code: String) -> void:
	start_button.change_text()
	fullscreen_button.change_text()

func on_quit_game() -> void:
	get_tree().quit()

func on_start_game(savegame_id) -> void:
	if transitioning:
		return
	transitioning = true
	TransitionScreen.transition(3)
	await TransitionScreen.on_transition_finished
	var is_new_game = true if savegame_id not in existing_save_nums else false
	if savegame_id == null:
		savegame_id = get_smallest_missing_int(save_nums)
	Global.start_game(savegame_id, is_new_game)
	queue_free()

func on_start_tutorial() -> void:
	if transitioning:
		return
	transitioning = true
	TransitionScreen.transition(3)
	await TransitionScreen.on_transition_finished
	Global.start_tutorial()
	queue_free()

func change_display_chums(save_num, show_particles = false) -> void:
	if fmod(camera_a, 2 * PI) > 0.8:
			camera_returning = true
	for node in team_node.get_node("chums").get_children():
		node.queue_free()
	
	if save_num in start_button.existing_save_nums:
		var chum_list = saved_chums[save_num]
		var chum_count = len(chum_list)
		
		var inc:int = 0
		for chum_id in chum_list:
			var chum_to_spawn = ChumsManager.get_specific_chum_id(chum_id)
			if chum_to_spawn:
				#Spawns chum
				var chum_instance = chum_to_spawn.instantiate()
				team_node.get_node("chums").add_child(chum_instance)
				var chum_position = team_node.global_position
				chum_position += Vector3(5.0 * sin(2*PI*inc/chum_count), 0, 5.0 * cos(2*PI*inc/chum_count))
				chum_instance.global_position = chum_position
				chum_instance.generalchumbehaviour.visible = false
				chum_instance.sleep_zone.queue_free()
				chum_instance.scale = Vector3(2.0, 2.0, 2.0)
				chum_instance.rotation.y = randf_range(0, 2*PI)
				chum_instance.anim_player.speed_scale = randf_range(0.8, 1.2)
				#Spawn spawn particles:
				if show_particles and team_node.visible:
					chum_instance.particle_zone.add_child(spawn_particles.instantiate())
			inc += 1
	
	#Check for bonus chum - if its a new game need to check what id it will start on!
	var this_save_id = save_num if save_num != null else get_smallest_missing_int(save_nums)
	if this_save_id not in SaverLoader.game_stats["bonus_chums"].keys():
		return
	var bonus_chum_id = SaverLoader.game_stats["bonus_chums"][this_save_id]["chum_id"]

	var bonus_chum = ChumsManager.get_specific_chum_id(bonus_chum_id).instantiate()
	team_node.get_node("chums").add_child(bonus_chum)
	bonus_chum.global_position = Vector3(0.0, 2.0, 3.0)
	bonus_chum.generalchumbehaviour.visible = false
	bonus_chum.sleep_zone.queue_free()
	bonus_chum.scale = Vector3(2.0, 2.0, 2.0)
	bonus_chum.rotation.y = randf_range(0, 2*PI)
	bonus_chum.anim_player.speed_scale = randf_range(0.8, 1.2)
	bonus_chum.add_child(bonus_chum_particles.instantiate())
	#Spawn spawn particles:
	if show_particles and team_node.visible:
		bonus_chum.particle_zone.add_child(spawn_particles.instantiate())

func get_smallest_missing_int(list) -> int:
	var lowest = 1
	for n in list:
		if n == lowest:
			lowest += 1
		elif n != null:
			break
	return lowest
