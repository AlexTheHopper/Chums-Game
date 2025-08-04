extends Chum
class_name Chum12
var chum_id := 12
var chum_str := "chum12"
var chum_name := "Ram"

var desc := "Just a cute waddling strange creature until it approaches you and rams into your shins with the power of a thousand suns. Won't be laughing then..."

var min_attack_speed := 1.3

var base_attack_speed := 1.75
var base_attack_damage := 30
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

var bracelet_count := 1 if not Global.dev_mode else 1
var bracelet_cost := 3 if not Global.dev_mode else 1
