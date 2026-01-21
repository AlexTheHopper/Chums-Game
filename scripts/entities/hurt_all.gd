extends Area3D
class_name HurtAll

@export var damage: int = 0

func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(11, true)
	set_collision_layer_value(12, true)

func _on_area_entered(hurtbox) -> void:
	if hurtbox == null or (hurtbox.owner is not Chum and hurtbox.owner is not Player) or hurtbox.owner.health_node.get_immune():
		return
	#Remove damage
	hurtbox.owner.health_node.health -= damage
