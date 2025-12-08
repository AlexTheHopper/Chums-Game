extends CharacterBody3D
class_name Chum

@export var jump_height: float = 2
@export var jump_peak_time: float = 0.3
@export var jump_fall_time: float = 0.25

@export var initial_state_override := ""

@onready var jump_velocity: float = (2.0 * jump_height) / jump_peak_time
@onready var jump_gravity: float = (-2.0 * jump_height) / (jump_peak_time ** 2)
@onready var fall_gravity: float = (-2.0 * jump_height) / (jump_fall_time ** 2)

var follow_distance := 10.0

@export var anim_player : AnimationPlayer
@export var body_mesh : MeshInstance3D
@export var sleep_zone : Node3D
@export var hitbox: Hitbox
@export var hurtbox: Hurtbox
@export var interaction_area : Area3D
@export var bracelet: Node3D
@export var sleep_particles : PackedScene = preload("res://particles/sleep_particles.tscn")

@onready var state_machine = $GeneralChumBehaviour.state_machine
@onready var nav_agent = $NavigationAgent3D
@onready var health_node = $GeneralChumBehaviour.health_node

@onready var red_overlay := preload("res://materials/outline_red.tres")
@onready var blue_overlay := preload("res://materials/outline_blue.tres")
@onready var black_overlay := preload("res://materials/outline_black.tres")

var current_group := "Chums_Neutral"
var previous_group := "Chums_Neutral"

@onready var particle_zone := $Particles
@onready var hurt_particles_enemy := load("res://particles/damage_enemy.tscn")
@onready var hurt_particles_friend := load("res://particles/damage_friendly.tscn")
@onready var hurt_particles := hurt_particles_enemy
@onready var heal_particles_enemy := load("res://particles/heal_enemy.tscn")
@onready var heal_particles_friend := load("res://particles/heal_friendly.tscn")
@onready var heal_particles := heal_particles_enemy
@onready var hurt_particles_num_enemy := load("res://particles/damage_num_enemy.tscn")
@onready var hurt_particles_num_friend := load("res://particles/damage_num_friendly.tscn")
@onready var hurt_particles_num := hurt_particles_num_enemy

var stats_set := false
var quality: Dictionary[String, int] = {"health": 0, "move_speed": 0, "attack_damage": 0, "attack_speed": 0}
var move_speed: float
var attack_speed: float
var start_health := -1
var max_move_speed: float
var temp_sleep_time: float
var is_temporary := false

@onready var has_quality_popup := false
@export var indicator_color := Color.from_rgba8(40, 40, 40, 255)
@export var being_particles: Node3D


@onready var target: Node
@onready var next_target: Node
var targeted_by := []
var player_is_near := false
var is_launched := false

signal health_depleted
signal spawn_currency(type, location)

func _ready() -> void:
	add_to_group("Chums_Neutral")
	body_mesh.set_material_overlay(black_overlay)
	
	#Needed so that when hit, only the hit enemy flashes red:
	body_mesh.mesh = body_mesh.mesh.duplicate()
	var material = body_mesh.mesh.surface_get_material(0)
	var material_u = material.duplicate()
	body_mesh.mesh.surface_set_material(0, material_u)
	
	health_node.health_depleted.connect(_on_health_health_depleted)
	hurtbox.recieved_damage.connect(_on_recieved_damage)
	health_node.health_changed.connect(_on_health_changed)
	rotation.y = randf() * 2 * PI
	
	set_collision_layer_value(1, false)
	set_collision_layer_value(4, true)
	
	#set_collision_mask_value(2, true) #Dont do this, so you cant push them in sleep.
	set_collision_mask_value(4, true)
	
	#Stats:
	move_speed = self.base_move_speed
	max_move_speed = move_speed * 5.0

	nav_agent.target_desired_distance = self.attack_distance
	nav_agent.avoidance_enabled = true
	health_node.immune = false
	
	if not stats_set:
		set_new_stats()
		#And make sure stat displays only what the chum can do:
		if not self.has_attack_speed:
			quality["attack_speed"] = 0
		if not self.has_attack_damage:
			quality["attack_damage"] = 0
		if not self.has_move_speed:
			quality["move_speed"] = 0
		if not self.has_health:
			quality["health"] = 0
		start_health = int(self.base_health * (1.0 + float(quality["health"]) / 10.0))
	set_stats_from_quality()
	if start_health >= 0:
		health_node.set_health(start_health)
	stats_set = true

	
	
	#If override, change to that state now after all is initialised:
	if initial_state_override:
		set_state(initial_state_override)
		initial_state_override = ""

func get_gravity_dir():
	return fall_gravity if velocity.y < 0.0 else jump_gravity
	
func set_new_stats() -> void:
	var new_quality = [-2, -1, 0, 1, 2].pick_random()
	quality["health"] = new_quality

	new_quality = [-2, -1, 0, 1, 2].pick_random()
	quality["move_speed"] = new_quality

	new_quality = [-2, -1, 0, 1, 2].pick_random()
	quality["attack_damage"] = new_quality

	new_quality = [-2, -1, 0, 1, 2].pick_random()
	quality["attack_speed"] = new_quality

func set_stats_from_quality() -> void:
	health_node.set_max_health_override(int(self.base_health * (1.0 + (float(quality["health"]) / 10.0))))

	move_speed = min(max_move_speed, self.base_move_speed * (1.0 + (float(quality["move_speed"]) / 10.0)))

	hitbox.damage = self.base_attack_damage * (1.0 + (float(quality["attack_damage"]) / 10.0))

	attack_speed = max(self.min_attack_speed, self.base_attack_speed * (1.0 - (float(quality["attack_speed"]) / 10.0)))


func increase_stats(attack_speed_count: int = 1, attack_damage_count: int = 1, move_speed_count: int = 1, health_count: int = 1) -> void:
	if self.has_health:
		quality["health"] += health_count

	if self.has_move_speed:
		quality["move_speed"] += move_speed_count

	if self.has_attack_damage:
		quality["attack_damage"] += attack_damage_count

	if self.has_attack_speed:
		quality["attack_speed"] += attack_speed_count
	
	#APPLY CHANGES
	set_stats_from_quality()

func create_sleep_particles():
	if Global.game_begun:
		sleep_zone.add_child(sleep_particles.instantiate())
		
func remove_sleep_particles():
	for child in sleep_zone.get_children():
		child.stop_emitting()
		
func enable_interaction():
	interaction_area.shape.disabled = false
func disable_interaction():
	interaction_area.shape.disabled = true

#Runs when enemy chums wake up from room activator if enemy
func wake_up():
	make_enemy()
	set_new_target()
	set_state("Wake")
	health_node.immune = false
	
func set_state(state):
	state_machine.on_child_transition(state_machine.current_state, state)

#Runs when friend chums fight from room activator if friend
func find_enemy():
	set_new_target()
	if state_machine.current_state.state_name != "Carry":
		set_state("Active")

func _on_recieved_damage(_damage, change_agro, attacker):
	if change_agro:
		if anim_player.get_current_animation() == "Attack":
			next_target = attacker
		else:
			if attacker is Player:
				set_target_to(attacker)
			elif attacker.state_machine.current_state.state_name == "Active":
				set_target_to(attacker)
			next_target = target

func _on_health_changed(difference):
	#Stop already fainted chums from making noise on room entry
	if initial_state_override == "Knock":
		return

	if difference < 0.0:
		call_deferred("damaged", -difference)
		if current_group == "Chums_Friend":
			AudioManager.create_3d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_CHUM_HURT_FRIENDLY)
		else:
			AudioManager.create_3d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_CHUM_HURT_NOT_FRIENDLY)

	elif difference > 0.0 and state_machine.current_state.state_name != "Sleep":
		call_deferred("healed", difference)
		if current_group == "Chums_Friend":
			AudioManager.create_3d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_CHUM_HEAL_FRIENDLY)
		else:
			AudioManager.create_3d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_CHUM_HEAL_NOT_FRIENDLY)

func damaged(amount):
	if stats_set and state_machine.current_state.state_name != "Knock":
		$Hurtbox/AnimationPlayer.play("Hurt")
		get_tree().get_first_node_in_group("Camera").trigger_shake(0.25)
		particle_zone.add_child(hurt_particles.instantiate())
	
		var hurt_num_inst = hurt_particles_num.instantiate()
		hurt_num_inst.get_child(0).mesh.text = "-" + str(amount)
		particle_zone.add_child(hurt_num_inst)

func healed(amount):
	if stats_set and state_machine.current_state.state_name != "Knock":
		particle_zone.add_child(heal_particles.instantiate())
		
		var heal_num_inst = hurt_particles_num.instantiate()
		heal_num_inst.get_child(0).mesh.text = "+" + str(amount)
		particle_zone.add_child(heal_num_inst)

func _on_health_health_depleted() -> void:
	#Stop already fainted chums from making noise on room entry
	if initial_state_override == "Knock":
		return

	if current_group == "Chums_Friend":
		AudioManager.create_3d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_CHUM_DEATH_FRIENDLY)
	elif not is_temporary:
		AudioManager.create_3d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_CHUM_DEATH_NOT_FRIENDLY)
		
		#Spawn Bracelets
		for n in self.bracelet_count:
			spawn_currency.emit("bracelet", global_position)
			
	if target:
		target.targeted_by.erase(self)
	
	get_tree().get_first_node_in_group("Camera").trigger_shake(0.5)
	set_state("Knock")
	
	health_depleted.emit()

func has_damage() -> bool:
	return health_node.get_health() < health_node.get_max_health()
	
func get_agro_change_target():
	return self

func put_to_sleep_temp(duration: float) -> void:
	if state_machine.current_state.state_name == "Carry":
		return
	temp_sleep_time += duration
	set_state("SleepTemp")
	
func make_enemy():
	remove_from_group("Chums_Friend")
	remove_from_group("Chums_Neutral")
	add_to_group("Chums_Enemy")
	previous_group = current_group
	current_group = "Chums_Enemy"
	body_mesh.set_material_overlay(red_overlay)
	if hitbox:
		hitbox.set_as_enemy()
		hurtbox.set_as_enemy()
	hurt_particles = hurt_particles_enemy
	hurt_particles_num = hurt_particles_num_enemy
	heal_particles = heal_particles_enemy
	
	if bracelet:
		bracelet.make_invisible()
		
	if nav_agent:
		nav_agent.set_avoidance_layer_value(1, false)
		nav_agent.set_avoidance_layer_value(2, true)
		nav_agent.set_avoidance_mask_value(1, false)
		nav_agent.set_avoidance_mask_value(2, true)
	
func make_friendly(to_heal = true):
	remove_from_group("Chums_Enemy")
	remove_from_group("Chums_Neutral")
	add_to_group("Chums_Friend")
	previous_group = current_group
	current_group = "Chums_Friend"
	body_mesh.set_material_overlay(blue_overlay)
	if hitbox:
		hitbox.set_as_friendly()
		hurtbox.set_as_friendly()
	hurt_particles = hurt_particles_friend
	hurt_particles_num = hurt_particles_num_friend
	heal_particles = heal_particles_friend
	
	if bracelet:
		bracelet.make_visible()
		
	if nav_agent:
		nav_agent.set_avoidance_layer_value(1, true)
		nav_agent.set_avoidance_layer_value(2, false)
		nav_agent.set_avoidance_mask_value(1, true)
		nav_agent.set_avoidance_mask_value(2, false)
	
	#Reset health to full:
	if to_heal:
		health_node.set_health(health_node.get_max_health())
	
	PlayerStats.player_chums_befriended += 1
	if self.chum_id not in PlayerStats.player_unique_chums_befriended:
		PlayerStats.player_unique_chums_befriended.append(self.chum_id)
	
func make_neutral():
	remove_from_group("Chums_Enemy")
	remove_from_group("Chums_Friend")
	add_to_group("Chums_Neutral")
	previous_group = current_group
	current_group = "Chums_Neutral"
	body_mesh.set_material_overlay(black_overlay)
	if hitbox:
		hitbox.set_as_neutral()
		hurtbox.set_as_neutral()
	hurt_particles = hurt_particles_enemy
	hurt_particles_num = hurt_particles_num_enemy
	heal_particles = heal_particles_enemy
	
	if bracelet:
		bracelet.make_invisible()
		
	if nav_agent:
		nav_agent.set_avoidance_layer_value(1, false)
		nav_agent.set_avoidance_layer_value(2, false)
		nav_agent.set_avoidance_mask_value(1, false)
		nav_agent.set_avoidance_mask_value(2, false)
	
func attempt_carry():
	var is_friend = current_group == "Chums_Friend"
	
	#Player must not be full of friends:
	if PlayerStats.is_chum_list_full() and not is_friend:
		PlayerStats.emit_too_many_chums()
		return
	#Player must not already be carrying a chum
	if get_tree().get_first_node_in_group("Player").is_carrying:
		return
	
	#If chum is enemy and not enough bracelets:
	if not is_friend and PlayerStats.bracelets < self.bracelet_cost:
		PlayerStats.emit_insufficient_bracelets()
		return
		
	#WORKS if chum is friend OR have enough bracelets.
	if is_friend or PlayerStats.bracelets >= self.bracelet_cost:
		if not is_friend:
			PlayerStats.bracelets_added(-self.bracelet_cost)
			PlayerStats.call_deferred("friend_chums_changed", 1, self)
		get_tree().get_first_node_in_group("Player").is_carrying = true
		set_state("Carry")

func do_attack(_attack_name):
	anim_player.play("Attack")
	
	#Check target, sometimes a chum will stay locked on even if it is knocked.
	if not target:
		return
	if target is not Chum:
		return
	if target.state_machine.current_state.state_name == "Knock":
		set_new_target()

func set_new_target():
	var body: Node

	#Disconnect from previous chum:
	if target:
		target.targeted_by.erase(self)
		var old_target_health = target.health_node
		if old_target_health.health_depleted.is_connected(_on_target_death):
			old_target_health.health_depleted.disconnect(_on_target_death)

	#Set initial target for chum
	if is_in_group("Chums_Friend"):
		body = Functions.get_closest_chum_in_group(self, "Chums_Enemy")
		
	else:
		#Target closest friendly chum / player.
		var closest_chum_friend = Functions.get_closest_chum_in_group(self, "Chums_Friend")
		var player = get_tree().get_first_node_in_group("Player")
		
		if not closest_chum_friend or self.always_targets_player:
			body = player
		elif Functions.distance_squared(self, closest_chum_friend) < Functions.distance_squared(self, player):
			body = closest_chum_friend
		else:
			body = player

	target = body
	if target:
		target.targeted_by.append(self)
		next_target = target
	
		#Connect to target to know when it dies:
		var new_target_health = target.health_node
		new_target_health.health_depleted.connect(_on_target_death)
		
func set_target_to(new_target):
	#Disconnect from previous chum:
	if target:
		target.targeted_by.erase(self)
		var old_target_health = target.health_node
		if old_target_health.health_depleted.is_connected(_on_target_death):
			old_target_health.health_depleted.disconnect(_on_target_death)
	
	target = new_target
	if target:
		target.targeted_by.append(self)
	
	#Connect to target to know when it dies:
	if target:
		var new_target_health = target.health_node
		new_target_health.health_depleted.connect(_on_target_death)
		
func _on_target_death():
	if target:
		set_new_target()
		if not self.target and state_machine.current_state.state_name != "Carry":
			set_state("Idle")
