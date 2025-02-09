extends Area3D
class_name Hitbox

@export var damage: float = 1 : set = set_damage, get = get_damage
@export var active: bool = false

func _ready() -> void:
	#Set correct layer/mask collisions:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	var parent_group = get_parent_group(self)
	if parent_group in ["Chums_Enemy"]:
		set_as_enemy()
	elif parent_group in ["Chums_Friend", "Player"]:
		set_as_friendly()
		
#Goes up tree until a node is in a group, returns that group name as str
func get_parent_group(node):
	if len(node.get_groups()) > 0:
		return node.get_groups()[0]
	elif node.get_parent():
		return get_parent_group(node.get_parent())
	else:
		return false
		
func set_as_enemy():
	set_collision_layer_value(10, true)
	
func set_as_friendly():
	set_collision_layer_value(9, true)
	
func set_as_neutral():
	set_collision_layer_value(9, false)
	set_collision_layer_value(10, false)
	

func set_damage(value: float):
	damage = value
	
func get_damage() -> float:
	return damage
