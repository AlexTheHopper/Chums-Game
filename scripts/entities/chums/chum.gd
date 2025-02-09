extends CharacterBody3D
class_name Chum

@export var jump_height: float = 2
@export var jump_peak_time: float = 0.3
@export var jump_fall_time: float = 0.25

@onready var jump_velocity: float = (2.0 * jump_height) / jump_peak_time
@onready var jump_gravity: float = (-2.0 * jump_height) / (jump_peak_time ** 2)
@onready var fall_gravity: float = (-2.0 * jump_height) / (jump_fall_time ** 2)

@onready var state_machine := $State_Machine
@onready var red_overlay := preload("res://materials/outline_red.tres")
@onready var blue_overlay := preload("res://materials/outline_blue.tres")
@export var hitbox: Hitbox
@export var hurtbox: Hurtbox

@onready var target: Node

@onready var initial_state_override = null

signal health_depleted

func _ready() -> void:
	rotation.y = randf() * 2 * PI

func get_gravity_dir():
	return fall_gravity if velocity.y < 0.0 else jump_gravity
	
#Runs when enemy chums wake up from room activator
func wake_up():
	make_enemy()
	state_machine.on_child_transition(state_machine.current_state, 'Wake')
	$Health.immune = false
	hitbox.damage = 1
	hitbox.active = true

#Runs when friend chums fight from room activator
func find_enemy():
	set_new_target()
	if state_machine.current_state.state_name != "Carry":
		state_machine.on_child_transition(state_machine.current_state, 'Attack')

func _on_health_health_depleted() -> void:
	state_machine.on_child_transition(state_machine.current_state, 'Knock')
	hitbox.active = false
	health_depleted.emit()
	
func make_enemy():
	remove_from_group("Chums_Friend")
	remove_from_group("Chums_Neutral")
	add_to_group("Chums_Enemy")
	$MeshInstance3D.set_material_overlay(red_overlay)
	hitbox.set_as_enemy()
	hurtbox.set_as_enemy()
	
func make_friendly():
	remove_from_group("Chums_Enemy")
	remove_from_group("Chums_Neutral")
	add_to_group("Chums_Friend")
	$MeshInstance3D.set_material_overlay(blue_overlay)
	hitbox.set_as_friendly()
	hurtbox.set_as_friendly()
	
	#Reset health to full:
	$Health.set_health($Health.get_max_health())
	
func make_neutral():
	remove_from_group("Chums_Enemy")
	remove_from_group("Chums_Friend")
	add_to_group("Chums_Neutral")
	$MeshInstance3D.set_material_overlay(null)
	hitbox.set_as_neutral()
	hurtbox.set_as_neutral()
	
func attempt_carry():
	if not get_tree().get_first_node_in_group("Player").is_carrying:
		get_tree().get_first_node_in_group("Player").is_carrying = true
		state_machine.on_child_transition(state_machine.current_state, 'Carry')
	
	
func set_new_target():
	var body: Node
	#Set initial target for chum
	if is_in_group("Chums_Friend"):
		body = Functions.get_closest_chum_in_group(self, "Chums_Enemy")
		
	else:
		body = Functions.get_closest_chum_in_group(self, "Chums_Friend")
		
		#If no friend chums, set to player:
		if not body:
			body = get_tree().get_first_node_in_group("Player")
	self.target = body
	
	#Connect to target to know when it dies:
	if self.target:
		var health_node = self.target.get_node("Health")
		health_node.health_depleted.connect(_on_target_death)
		

func _on_target_death():
	set_new_target()
	if not self.target and state_machine.current_state.state_name != "Carry":
		state_machine.on_child_transition(state_machine.current_state, 'Idle')
		
