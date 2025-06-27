extends Chum
class_name Chum3
var chum_str := "chum3"
var chum_name := "Pear"

var desc := "Lurking in the shadows, and waiting for more prey is a chum with a very pointy stick. It may be slow, but golly gosh, that stick works wonders. Those wonders being inflicting a lot of pain."

var min_attack_speed := 2.55

var base_attack_speed := 3.2
var base_attack_damage := 40
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
