extends Area3D
class_name Hurtbox

signal recieved_damage(damage: float, change_agro: bool)

@export var entity: CharacterBody3D
var health_node: Node

@onready var changes_agro_on_damaged = owner.changes_agro_on_damaged

func _ready() -> void:
	await entity.ready
	health_node = entity.health_node
	connect("area_entered", _on_area_entered)
	#Set correct layer/mask collisions:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	var parent_group = owner.get_groups()[0]
	if parent_group in ["Chums_Enemy"]:
		set_as_enemy()
	elif parent_group in ["Chums_Friend", "Player"]:
		set_as_friendly()
		
		
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
		var maintains_agro = false
		if "target" in owner:
			maintains_agro = owner.target.maintains_agro

		if changes_agro_on_damaged and hitbox.draws_agro_on_attack and not maintains_agro:
			change_agro = true

		recieved_damage.emit(hitbox.damage, change_agro)
