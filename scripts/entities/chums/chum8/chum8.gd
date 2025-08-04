extends Chum
class_name Chum8
var chum_id := 8
var chum_str := "chum8"
var chum_name := "Bolt"

var desc := "Just a silly little guy! With no defense mechanisms, it seems Evolution should have forgotten it long ago. Although, Bolt will distract enemies attention 80% of the time!"

var min_attack_speed := 3.8

var base_attack_speed := 3.85
var base_attack_damage := 0.0
var base_move_speed := 7.5
var base_health := 50
#Control of qualities
var has_attack_speed := false
var has_attack_damage := false
var has_move_speed := true
var has_health := true

var attack_distance := 1.3
var knockback_strength := 0.0
var knockback_weight := 0.75

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.8
var changes_agro_on_damaged := true
var draws_agro_on_attack := false
var always_targets_player := false

var bracelet_count := 1 if not Global.dev_mode else 1
var bracelet_cost := 3 if not Global.dev_mode else 1

var target_room_types := ["lobby", "room", "fountain", "void", "upgrade", "statue"]
var can_seek := true
