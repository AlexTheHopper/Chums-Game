extends Chum
class_name Chum10
var chum_id := 10

var min_attack_speed := 2.1

var base_attack_speed := 5.0
var base_attack_damage := 5
var base_move_speed := 1.0
var base_health := 100
#Control of qualities
var has_attack_speed := true
var has_attack_damage := true
var has_move_speed := true
var has_health := true

var attack_distance := 20.0
var knockback_strength := 0.0
var knockback_weight := 0.5

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1
var bracelet_cost := 3

@export var projectile: PackedScene

func throw():
	var targets: Array
	if self.current_group == "Chums_Enemy":
		targets = get_tree().get_nodes_in_group("Chums_Friend")
		targets.append(get_tree().get_first_node_in_group("Player"))
	else:
		targets = get_tree().get_nodes_in_group("Chums_Enemy")
	
	for entity in targets:
		var throw_inst = projectile.instantiate()
		throw_inst.target = entity
		throw_inst.origin = self
		throw_inst.position_ = self.sleep_zone.global_position
		Global.current_room_node.get_node("Decorations").add_child(throw_inst)
