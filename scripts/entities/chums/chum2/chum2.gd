extends Chum
class_name Chum2
var chum_str := "chum2"
var chum_name := "Stump"

var desc := "This wooden chum was once part of a local tree, until a quite rude lumberjack decided that ol' stumpy didn't need its family anymore. These days it spends its time attacking anything unfamiliar with its signature spin attack."

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

var attack_distance := 0.85

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1 if not Global.dev_mode else 1
var bracelet_cost := 3 if not Global.dev_mode else 1
