extends Area3D
class_name Hitbox

@onready var attack_info: Dictionary
@export var damage: float = 0.0 : set = set_damage, get = get_damage

@onready var draws_agro_on_attack = owner.draws_agro_on_attack

func _ready() -> void:
	#Set correct layer/mask collisions:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	var parent_group = Functions.get_parent_group(self)
	if parent_group in ["Chums_Enemy"]:
		set_as_enemy()
	elif parent_group in ["Chums_Friend", "Player"]:
		set_as_friendly()
		
func set_as_enemy():
	set_collision_layer_value(10, true)
	
	set_collision_layer_value(9, false)
	
func set_as_friendly():
	set_collision_layer_value(9, true)
	
	set_collision_layer_value(10, false)
	
func set_as_neutral():
	set_collision_layer_value(9, false)
	set_collision_layer_value(10, false)
	

func set_damage(value: float):
	damage = value
	
func get_damage() -> float:
	return damage
