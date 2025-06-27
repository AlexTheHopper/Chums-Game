extends Chum
class_name Chum4
var chum_str := "chum4"
var chum_name := "Jabby"

var desc := "No one is really sure where this chum comes from. It seems a little out of place a lot of the time and its very unclear which direction its looking, without eyes and all. With its tail it goes jabby-jab in quick succession."

var min_attack_speed := 1.88

var base_attack_speed := 2.5
var base_attack_damage := 10
var base_move_speed := 1.0
var base_health := 100
#Control of qualities
var has_attack_speed := true
var has_attack_damage := true
var has_move_speed := true
var has_health := true

var attack_distance := 1.3


#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1 if not Global.dev_mode else 1
var bracelet_cost := 3 if not Global.dev_mode else 1
