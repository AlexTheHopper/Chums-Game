extends Chum
class_name Chum9
var chum_id := 9
var chum_str := "chum9"
var chum_name := "Fan"


var desc := "TODO"

var min_attack_speed := 1.7

var base_attack_speed := 1.75
var base_attack_damage := 5
var base_move_speed := 0.0
var base_health := 150
#Control of qualities
var has_attack_speed := true
var has_attack_damage := true
var has_move_speed := false
var has_health := true

var attack_distance := 1.5

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1 if not Global.dev_mode else 1
var bracelet_cost := 3 if not Global.dev_mode else 1
