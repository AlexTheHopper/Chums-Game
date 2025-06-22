extends Chum
class_name Chum2
var chum_str := "chum2"
var chum_name := "Stump"

var desc := "This wooden chum was once part of a local tree, until a quite rude lumberjack decided that ol' stumpy didn't need its family anymore. These days it spends its time attacking anything unfamiliar with its signature spin attack."

@onready var default_attack: Dictionary = {"speed": 3.5, #fastest quality still needs to be more than the attack animation length.
										"damage": 15,
										"distance": 0.85,
										"single_target": true}

var default_move_speed := 0.75
var can_walk := true

var max_health := 100
var start_health := 100

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1 if not Global.dev_mode else 1
var bracelet_cost := 3 if not Global.dev_mode else 1
