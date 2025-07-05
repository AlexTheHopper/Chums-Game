extends Area3D
class_name Hurtbox

signal recieved_damage(damage: int, change_agro: bool)

var health_node: Node

@onready var changes_agro_on_damaged = owner.changes_agro_on_damaged

func _ready() -> void:
	await owner.ready
	health_node = owner.health_node
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
	if hitbox == null or owner.health_node.get_immune():
		return
	#Remove damage
	health_node.health -= hitbox.damage
	
	var change_agro: bool
	change_agro = change_agression(hitbox)
	apply_knockback(owner, hitbox.owner)

	recieved_damage.emit(hitbox.damage, change_agro, hitbox.owner.get_agro_change_target())

func change_agression(hitbox) -> bool:
	#Check to change agression
	var change_agro = false
	var maintains_agro = false
	if owner and "target" in owner:
		if owner.target:
			if "maintains_agro" in owner.target:
				if randf() < owner.target.maintains_agro:
					maintains_agro = true
	if changes_agro_on_damaged and hitbox.draws_agro_on_attack and not maintains_agro:
		change_agro = true
	return change_agro

func apply_knockback(target, source) -> void:
	var strength: float = source.knockback_strength
	if is_zero_approx(strength):
		return

	var y_strength: float = strength / 2.0

	var impulse: Vector3 = Functions.vector_to_normalized(source, target) * strength / target.knockback_weight
	impulse.y = max(y_strength, 0)
	
	target.velocity = impulse
	target.is_launched = true
	target.move_and_slide() # Otherwise the chum checks if touching floor before moving, immediately changing is_launched to false

	if target is Player:
		target.anim_player.call_deferred("play", "Jump_Carry" if target.is_carrying else "Jump_noCarry")
