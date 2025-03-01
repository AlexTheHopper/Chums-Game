extends CharacterBody3D
class_name Chum

@export var jump_height: float = 2
@export var jump_peak_time: float = 0.3
@export var jump_fall_time: float = 0.25

@onready var jump_velocity: float = (2.0 * jump_height) / jump_peak_time
@onready var jump_gravity: float = (-2.0 * jump_height) / (jump_peak_time ** 2)
@onready var fall_gravity: float = (-2.0 * jump_height) / (jump_fall_time ** 2)

var follow_distance = 10.0

@onready var state_machine = $GeneralChumBehaviour.state_machine
@onready var nav_agent = $NavigationAgent3D
@onready var health_node = $GeneralChumBehaviour.health_node
@export var anim_player : AnimationPlayer
@export var body_mesh : MeshInstance3D
@onready var red_overlay := preload("res://materials/outline_red.tres")
@onready var blue_overlay := preload("res://materials/outline_blue.tres")
@onready var black_overlay := preload("res://materials/outline_black.tres")
@export var sleep_zone : Node3D
@export var sleep_particles : PackedScene
var current_group := "Chums_Neutral"
@onready var bracelet := $Body/Armature/Skeleton3D/BoneAttachment3D/Bracelet
@export var hitbox: Hitbox
@export var hurtbox: Hurtbox
@onready var particle_zone := $Particles

var stats_set = false
@onready var attack: Dictionary
@onready var move_speed: float
var quality := {"damage": 0, "speed": 0, "move_speed": 0}
@export var interraction_area : Area3D
@export var interraction_area_shape : CollisionShape3D
@onready var has_quality_popup := false

@onready var target: Node
var targeted_by := []
@onready var player_is_near := false

var initial_state_override = null

signal health_depleted
signal spawn_currency(type, location)


func _ready() -> void:
	health_node.health_depleted.connect(_on_health_health_depleted)
	hurtbox.recieved_damage.connect(_on_recieved_damage)
	rotation.y = randf() * 2 * PI
	
	if not stats_set:
		attack = self.default_attack
		move_speed = self.default_move_speed
		set_new_stats()
	
	#Otherwise, attack and move_speed are set by room.gd
	hitbox.attack_info = attack
	hitbox.damage = attack["damage"]
	$NavigationAgent3D.target_desired_distance = attack["distance"]
	$NavigationAgent3D.path_desired_distance = attack["distance"]
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
	self.attack["damage"] *= multiplier
	quality["damage"] = 10 * (multiplier - 1)
	
	multiplier = [0.8, 0.9, 1.0, 1.1, 1.2].pick_random()
	self.move_speed *= multiplier
	quality["move_speed"] = 10 * (multiplier - 1)
	
func create_sleep_particles():
	sleep_zone.add_child(sleep_particles.instantiate())
		
func remove_sleep_particles():
	for child in sleep_zone.get_children():
		child.queue_free()
	
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

func _on_recieved_damage(_damage, change_agro, _attacker):
	if change_agro:
		set_new_target()

func _on_health_health_depleted() -> void:
	if current_group == "Chums_Enemy":
		for n in self.bracelet_count:
			spawn_currency.emit("bracelet", global_position)
			
	if target:
		target.targeted_by.erase(self)
	
			
	set_state("Knock")
	health_depleted.emit()
	
func make_enemy():
	remove_from_group("Chums_Friend")
	remove_from_group("Chums_Neutral")
	add_to_group("Chums_Enemy")
	current_group = "Chums_Enemy"
	body_mesh.set_material_overlay(red_overlay)
	hitbox.set_as_enemy()
	hurtbox.set_as_enemy()
	
	if bracelet:
		bracelet.make_invisible()
		
	if $NavigationAgent3D:
		$NavigationAgent3D.set_avoidance_layer_value(1, false)
		$NavigationAgent3D.set_avoidance_layer_value(2, true)
		$NavigationAgent3D.set_avoidance_mask_value(1, false)
		$NavigationAgent3D.set_avoidance_mask_value(2, true)
	
func make_friendly():
	remove_from_group("Chums_Enemy")
	remove_from_group("Chums_Neutral")
	add_to_group("Chums_Friend")
	current_group = "Chums_Friend"
	body_mesh.set_material_overlay(blue_overlay)
	hitbox.set_as_friendly()
	hurtbox.set_as_friendly()
	
	if bracelet:
		bracelet.make_visible()
		
	if $NavigationAgent3D:
		$NavigationAgent3D.set_avoidance_layer_value(1, true)
		$NavigationAgent3D.set_avoidance_layer_value(2, false)
		$NavigationAgent3D.set_avoidance_mask_value(1, true)
		$NavigationAgent3D.set_avoidance_mask_value(2, false)
	
	#Reset health to full:
	health_node.set_health(health_node.get_max_health())
	
func make_neutral():
	remove_from_group("Chums_Enemy")
	remove_from_group("Chums_Friend")
	add_to_group("Chums_Neutral")
	current_group = "Chums_Neutral"
	body_mesh.set_material_overlay(black_overlay)
	hitbox.set_as_neutral()
	hurtbox.set_as_neutral()
	
	if bracelet:
		bracelet.make_invisible()
		
	if $NavigationAgent3D:
		$NavigationAgent3D.set_avoidance_layer_value(1, false)
		$NavigationAgent3D.set_avoidance_layer_value(2, false)
		$NavigationAgent3D.set_avoidance_mask_value(1, false)
		$NavigationAgent3D.set_avoidance_mask_value(2, false)
	
func attempt_carry():
	#Player must not already be carrying a chum
	if not get_tree().get_first_node_in_group("Player").is_carrying:
		#If the chum is not friendly, need to pay in bracelets
		if current_group == "Chums_Friend" or PlayerStats.bracelets >= self.bracelet_cost:
			if current_group != "Chums_Friend":
				PlayerStats.bracelets_added(-self.bracelet_cost)
			get_tree().get_first_node_in_group("Player").is_carrying = true
			set_state("Carry")

func do_attack(_attack_name):
	anim_player.play("Attack")

func set_new_target():
	var body: Node

	#Disconnect from previoud chum:
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
		
		if not closest_chum_friend:
			body = player
		elif Functions.distance_squared(self, closest_chum_friend) < Functions.distance_squared(self, player):
			body = closest_chum_friend
		else:
			body = player

	self.target = body
	if self.target:
		self.target.targeted_by.append(self)
	
	#Connect to target to know when it dies:
	if self.target:
		var new_target_health = self.target.health_node
		new_target_health.health_depleted.connect(_on_target_death)
		
func _on_target_death():
	set_new_target()
	if not self.target and state_machine.current_state.state_name != "Carry":
		set_state("Idle")
		
