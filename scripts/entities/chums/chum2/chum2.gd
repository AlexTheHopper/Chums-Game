extends Chum
class_name Chum2
var chum_id := 2

var min_attack_speed := 1.7

var base_attack_speed := 3.5
var base_attack_damage := 15
var base_move_speed := 0.75
var base_health := 100
#Control of qualities
var has_attack_speed := true
var has_attack_damage := true
var has_move_speed := true
var has_health := true

var attack_distance := 1.0
var knockback_strength := 0.0
var knockback_weight := 1.5

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1
var bracelet_cost := 3
