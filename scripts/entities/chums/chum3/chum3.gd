extends Chum
class_name Chum3
var chum_str := "chum3"
var chum_name := "Pear"

var desc := "CHUM 3 DESC."

@onready var default_attack: Dictionary = {"speed": 3.2, #fastest quality still needs to be more than the attack animation length.
										"damage": 3.0,
										"distance": 1.3,
										"single_target": true}

var default_move_speed = 1.5

var max_health := 10.0
var start_health := 10.0

var maintains_agro := false
var changes_agro_on_damaged := true
var draws_agro_on_attack := true

var bracelet_count := 3
var bracelet_cost := 3
