extends Chum
class_name Chum7
var chum_str := "chum7"
var chum_name := "Ring of Pearls"


var desc := "TODO."

@onready var default_attack: Dictionary = {"speed": 1.6, #fastest quality still needs to be more than the attack animation length.
										"damage": 10,
										"distance": 1.3,
										"single_target": true}

var default_move_speed := 0.0
var can_walk := false

var max_health := 100
var start_health := 100

var maintains_agro := false
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 3
var bracelet_cost := 3
