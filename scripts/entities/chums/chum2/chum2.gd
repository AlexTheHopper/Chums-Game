extends Chum
class_name Chum2
var chum_str := "chum2"
var chum_name := "Stump"

var desc := "This wooden chum was once part of a local tree, until a quite rude lumberjack decided that ol' stumpy didn't need its family anymore. These days it spends its time attacking anything unfamiliar with its signature spin attack."

@onready var default_attack: Dictionary = {"speed": 3.5, #fastest quality still needs to be more than the attack animation length.
										"damage": 1.5,
										"distance": 0.85,
										"single_target": true}

var default_move_speed := 0.75

var max_health := 10.0
var start_health := 10.0

var maintains_agro := false
var changes_agro_on_damaged := true
var draws_agro_on_attack := true

var bracelet_count := 3
var bracelet_cost := 3
