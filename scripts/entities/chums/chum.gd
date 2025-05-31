extends CharacterBody3D
class_name Chum

@export var jump_height: float = 2
@export var jump_peak_time: float = 0.3
@export var jump_fall_time: float = 0.25

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
@onready var attack: Dictionary
@onready var move_speed: float
var quality := {"damage": 0, "speed": 0, "move_speed": 0}

@onready var has_quality_popup := false

@onready var target: Node
var targeted_by := []
var player_is_near := false
var is_launched := false

var initial_state_override = null

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
	
	if not stats_set:
		attack = self.default_attack
		move_speed = self.default_move_speed
		set_new_stats()
	
	#Otherwise, attack and move_speed are set by room.gd
	if hitbox:
		hitbox.attack_info = attack
		hitbox.damage = attack["damage"]
	nav_agent.target_desired_distance = attack["distance"]
	nav_agent.avoidance_enabled = true
	health_node.immune = false
	health_node.set_max_health_override(self.max_health)
	health_node.set_health_override(self.start_health)
	health_node.immune = true
	
func get_gravity_dir():
	return fall_gravity if velocity.y < 0.0 else jump_gravity
	
func set_new_stats():
	var multiplier = [0.8, 0.9, 1.0, 1.1, 1.2].pick_random()
	self.attack["speed"] *= multiplier
	quality["speed"] = 10 * (1 - multiplier)
	
	multiplier = [0.8, 0.9, 1.0, 1.1, 1.2].pick_random()
	self.attack["damage"] = int(self.attack["damage"] * multiplier)
	quality["damage"] = 10 * (multiplier - 1)
	
	multiplier = [0.8, 0.9, 1.0, 1.1, 1.2].pick_random()
	self.move_speed *= multiplier
	quality["move_speed"] = 10 * (multiplier - 1)
	
func create_sleep_particles():
	sleep_zone.add_child(sleep_particles.instantiate())
		
func remove_sleep_particles():
	for child in sleep_zone.get_children():
		child.queue_free()
		
func enable_interaction():
	interaction_area.shape.disabled = false
func disable_interaction():
	interaction_area.shape.disabled = true
	pass
	
#Runs when enemy chums wake up from room activator
func wake_up():
	make_enemy()
	set_state("Wake")
	health_node.immune = false
	
func set_state(state):
	state_machine.on_child_transition(state_machine.current_state, state)

#Runs when friend chums fight from room activator
func find_enemy():
	set_new_target()
	if state_machine.current_state.state_name != "Carry":
		set_state("Active")

func _on_recieved_damage(_damage, change_agro, attacker):
	if change_agro:
		if attacker is Player:
			set_target_to(attacker)
		elif attacker.state_machine.current_state.state_name == "Active":
			set_target_to(attacker)

func _on_health_changed(difference):
	if difference < 0.0:
		damaged(-difference)
	elif difference > 0.0 and state_machine.current_state.state_name != "Sleep":
		healed(difference)

func damaged(amount):
	if state_machine.current_state.state_name != "Knock":
		$Hurtbox/AnimationPlayer.play("Hurt")
		particle_zone.add_child(hurt_particles.instantiate())
	
		var hurt_num_inst = hurt_particles_num.instantiate()
		hurt_num_inst.get_child(0).mesh.text = "-" + str(amount)
		particle_zone.add_child(hurt_num_inst)

func healed(amount):
	if state_machine.current_state.state_name != "Knock":
		particle_zone.add_child(heal_particles.instantiate())
		
		var heal_num_inst = hurt_particles_num.instantiate()
		heal_num_inst.get_child(0).mesh.text = "+" + str(amount)
		particle_zone.add_child(heal_num_inst)

func _on_health_health_depleted() -> void:
	if current_group == "Chums_Enemy":
		for n in self.bracelet_count:
			spawn_currency.emit("bracelet", global_position)
			
	if target:
		target.targeted_by.erase(self)
	
			
	set_state("Knock")
	health_depleted.emit()
	
func has_damage() -> bool:
	return health_node.get_health() < health_node.get_max_health()
	
func get_agro_change_target():
	return self
	
func make_enemy():
	remove_from_group("Chums_Friend")
	remove_from_group("Chums_Neutral")
	add_to_group("Chums_Enemy")
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
	
func make_friendly():
	remove_from_group("Chums_Enemy")
	remove_from_group("Chums_Neutral")
	add_to_group("Chums_Friend")
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
	health_node.set_health(health_node.get_max_health())
	
func make_neutral():
	remove_from_group("Chums_Enemy")
	remove_from_group("Chums_Friend")
	add_to_group("Chums_Neutral")
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
			PlayerStats.call_deferred("friend_chums_changed")
		get_tree().get_first_node_in_group("Player").is_carrying = true
		set_state("Carry")

func do_attack(_attack_name):
	anim_player.play("Attack")

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
		var old_target_name = target.chum_name
		var new_target_name = 'None'
		set_new_target()
		if target:
			if not target is Player:
				new_target_name = target.chum_name
			elif target is Player:
				new_target_name = "Player"
		print("Self: " + str(self.chum_name) + ". Group: " + str(current_group) + '. Old Target: ' + str(old_target_name) + '. New target: ' + str(new_target_name))
		if not self.target and state_machine.current_state.state_name != "Carry":
			set_state("Idle")
		
