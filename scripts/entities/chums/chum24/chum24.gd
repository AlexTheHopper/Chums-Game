extends Chum
class_name Chum24
var chum_id := 24
var chum_str := "chum24"
var chum_name := "Bumble"

var desc := "Buzz buzz, and such."

var min_attack_speed := 1.3

var base_attack_speed := 1.75
var base_attack_damage := 10
var base_move_speed := 2.5
var base_health := 50
#Control of qualities
var has_attack_speed := true
var has_attack_damage := true
var has_move_speed := true
var has_health := true

var attack_distance := 0.85
var knockback_strength := 0.0
var knockback_weight := 1.0

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1
var bracelet_cost := 1


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Shrink":
		for targeting in self.targeted_by:
			if not targeting.is_queued_for_deletion():
				targeting.set_new_target()
		print('gone')
		#queue_free()
