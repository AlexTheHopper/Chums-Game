extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var team_node: Node3D = $DisplayNode
@onready var camera_a_start: float = 0
@onready var camera_a: float = camera_a_start

@export var start_button: Panel
@export var language_button: Panel
@export var tutorial_button: Panel
var buttons : Array[Panel]
var button_index := 0

var spawn_particles = preload("res://particles/spawn_particles_world1.tscn")
var transitioning := false
var camera_returning := false
var save_nums := []

var saved_chums: Dictionary = {null: []}

func _ready() -> void:
	buttons = [start_button, language_button, tutorial_button]
	buttons[button_index].on_selected()
	start_button.start_game.connect(on_start_game)
	start_button.save_changed.connect(change_display_chums)
	tutorial_button.start_tutorial.connect(on_start_tutorial)
	language_button.select_language.connect(update_language)

	var dir = DirAccess.open("user://saves")
	#Go through all files in saves
	for i_pot in dir.get_files():
		#Only append if it is .tres and named an integer
		if i_pot.ends_with(".tres") and i_pot.get_slice(".", 0).is_valid_int():
			#Append to list
			var this_save:int = int(i_pot.get_slice(".", 0))
			save_nums.append(this_save)
			
			#Get saved chums for display purposed
			saved_chums[this_save] = []
			var saved_game: SavedGame = load("user://saves/%s.tres" % [this_save])
			for chum in saved_game.friendly_chums:
				saved_chums[this_save].append(chum["id"])

	save_nums.append(null)
	save_nums.sort()
	start_button.save_nums = save_nums
	for button in buttons:
		button.initialise()

	AudioManager.create_music(SoundMusic.SOUND_MUSIC_TYPE.MENU)

func _process(delta: float) -> void:
	camera_a += delta / 25
	if fmod(camera_a, 2 * PI) < 0.5:
		camera_returning = false
	if transitioning:
		return
	
	if Input.is_action_just_pressed("cam_left") or Input.is_action_just_pressed("move_left"):
		buttons[button_index].left()
		if fmod(camera_a, 2 * PI) > 0.8:
			camera_returning = true
		
	elif Input.is_action_just_pressed("cam_right") or Input.is_action_just_pressed("move_right"):
		buttons[button_index].right()
		if fmod(camera_a, 2 * PI) > 0.8:
			camera_returning = true
	
	elif Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("attack"):
		buttons[button_index].interact()
	
	elif Input.is_action_just_pressed("move_forward") or Input.is_action_just_pressed("cam_up"):
		buttons[button_index].on_deselected()
		button_index = max(button_index - 1, 0)
		buttons[button_index].on_selected()
		
	elif Input.is_action_just_pressed("move_back") or Input.is_action_just_pressed("cam_down"):
		buttons[button_index].on_deselected()
		button_index = min(button_index + 1, buttons.size() - 1)
		buttons[button_index].on_selected()

func _physics_process(delta: float) -> void:
	if camera_returning:
		camera_a += delta * 5

	camera.global_position = Vector3(15 * sin(camera_a), 10, 15 * cos(camera_a))
	camera.rotation.y = camera_a - (PI / 4)

#This is needed as the save file string is a composit string and is not automatically translated.
func update_language(_lan_code: String) -> void:
	start_button.change_text()

func on_start_game(savegame_id) -> void:
	if transitioning:
		return
	transitioning = true
	TransitionScreen.transition(3)
	await TransitionScreen.on_transition_finished
	var is_new_game = true if savegame_id == null else false
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
	for node in team_node.get_node("chums").get_children():
		node.queue_free()
	
	if save_num == null:
		return
	
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
			chum_instance.get_node("GeneralChumBehaviour").visible = false
			#chum_instance.anim_player.play("Idle")
			chum_instance.sleep_zone.queue_free()
			chum_instance.scale = Vector3(2.0, 2.0, 2.0)
			chum_instance.rotation.y = randf_range(0, 2*PI)
			chum_instance.anim_player.speed_scale = randf_range(0.8, 1.2)
			#Spawn spawn particles:
			if show_particles and team_node.visible:
				chum_instance.particle_zone.add_child(spawn_particles.instantiate())
		inc += 1

func get_smallest_missing_int(list) -> int:
	var lowest = 1
	for n in list:
		if n == lowest:
			lowest += 1
		elif n != null:
			break
	return lowest
