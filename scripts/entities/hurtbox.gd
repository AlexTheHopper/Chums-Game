extends Area3D
class_name Hurtbox

signal recieved_damage(damage: float, change_agro: bool)

@export var entity: CharacterBody3D
var health_node: Node

@export var changes_agro_on_damaged: bool = true

func _ready() -> void:
	await entity.ready
	health_node = entity.health_node
	connect("area_entered", _on_area_entered)
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
	set_collision_layer_value(12, true)
	set_collision_mask_value(9, true)
	
	set_collision_mask_value(10, false)
	set_collision_mask_value(11, false)
	
func set_as_friendly():
	set_collision_layer_value(11, true)
	set_collision_mask_value(10, true)
	
	set_collision_layer_value(12, false)
	set_collision_layer_value(9, false)
	
func set_as_neutral():
	set_collision_layer_value(11, false)
	set_collision_layer_value(12, false)
	set_collision_mask_value(10, false)
	set_collision_mask_value(9, false)
	

func _on_area_entered(hitbox: Hitbox) -> void:
	if hitbox != null:
		health_node.health -= hitbox.damage
			
		#Check to change agression
		var change_agro = false
		if changes_agro_on_damaged and hitbox.draws_agro_on_attack:
			change_agro = true

		recieved_damage.emit(hitbox.damage, change_agro)
