extends Chum
class_name Chum1
var chum_id := 1
var chum_name := "Flamenco"

var desc := "This one-legged pink chum spends its whole day jumping around on its singular foot. With no opposable thumbs nor opposable wings, the only means of travel is hopping, and the only means of attacking prey is pecking. God has forsaken this chum as rather useless, as such it shall spend its days hopping around in search of more things to throw its head into."

var min_attack_speed := 1.25

var base_attack_speed := 1.6
var base_attack_damage := 10
var base_move_speed := 1.5
var base_health := 100
#Control of qualities
var has_attack_speed := true
var has_attack_damage := true
var has_move_speed := true
var has_health := true

var attack_distance := 1.3
var knockback_strength := 0.0
var knockback_weight := 1.0

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1
var bracelet_cost := 3
