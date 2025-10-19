extends Chum
class_name Chum23
var chum_id := 23
var chum_str := "chum23"
var chum_name := "Globe"

var desc := "Designed after the world itself. After several attempts, the satellites were deemed necessary for survival."

var min_attack_speed := 1.5

var base_attack_speed := 2.5
var base_attack_damage := 25
var base_move_speed := 1.5
var base_health := 150
#Control of qualities
var has_attack_speed := true
var has_attack_damage := true
var has_move_speed := true
var has_health := true

var attack_distance := 1.0
var knockback_strength := 0.0
var knockback_weight := 2.5

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1
var bracelet_cost := 3
