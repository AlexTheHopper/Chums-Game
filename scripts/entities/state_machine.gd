extends Node
class_name State_Machine

@export var initial_state: State

@onready var chum: CharacterBody3D = get_parent().get_parent()

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children() + chum.get_node("ChumSpecificStates").get_children():
		if child is State:
			child.chum = chum
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
			
			#if chum.initial_state_override:
				#if chum.initial_state_override.to_lower() == child.name.to_lower():
					#initial_state = child
		
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)
	
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)

func on_child_transition(state, new_state_name):
	#Cannot change from a different state
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		return
	#Cannot change to the same state:
	if state == new_state:
		return
		
	if current_state:
		current_state.Exit()
		
	new_state.Enter()
	
	current_state = new_state
	
