extends Chum
class_name Chum26
var chum_id := 26
var chum_name := "Granite"

var desc := "Such a studious flower. If flowers can be studious? This one has learned the ins and outs of all other chums, and upon defeat of an enemy, will occasionally up the ante and increase a friend's quality with a mysterious floating purple orb, for the cost of some of health. Provided that friend has no damage."

var min_attack_speed := 2.55

var base_attack_speed := 0.0
var base_attack_damage := 5
var base_move_speed := 0.0
var base_health := 50
#Control of qualities
var has_attack_speed := false
var has_attack_damage := true
var has_move_speed := false
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


var base_chance_to_ability := 0.3
var damage_self_on_ability := 15
