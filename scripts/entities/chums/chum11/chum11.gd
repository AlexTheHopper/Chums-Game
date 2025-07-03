extends Chum
class_name Chum11
var chum_id := 11
var chum_str := "chum11"
var chum_name := "Melly"

var desc := "Portable Melatonin! This little antennae friend doesn't do much by itself, however when defeated it lets out a burst of sleepyness, causing enemy chums to fall back asleep for a short while."

var min_attack_speed := 0.0

var base_attack_speed := 0.0
var base_attack_damage := 5
var base_move_speed := 0.0
var base_health := 100
#Control of qualities
var has_attack_speed := false
var has_attack_damage := false
var has_move_speed := false
var has_health := true

var attack_distance := 0.0
var knockback_strength := 0.0
var knockback_weight := 5.0

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1 if not Global.dev_mode else 1
var bracelet_cost := 3 if not Global.dev_mode else 1


#Chum specific stuff:
func sleep_attack_on_knock() -> void:
	if not Global.in_battle or self.temp_sleep_time > 0:
		return

	var sleep_time = self.hitbox.damage
	#Uses previous group as the group changes to neutral immediately on health depleted.
	if self.previous_group == "Chums_Friend":
		get_tree().call_group("Chums_Enemy", "put_to_sleep_temp", sleep_time)
	else:
		get_tree().call_group("Chums_Friend", "put_to_sleep_temp", sleep_time)
