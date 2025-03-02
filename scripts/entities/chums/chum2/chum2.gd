extends Chum
class_name Chum2
@onready var chum_name := "chum2"

var desc := "CHUM 2 DESC."

@onready var default_attack: Dictionary = {"speed": 3.5, #fastest quality still needs to be more than the attack animation length.
										"damage": 1.5,
										"distance": 0.85,
										"single_target": true}

var default_move_speed = 0.5

var max_health := 10.0
var start_health := 10.0

var maintains_agro := false
var changes_agro_on_damaged := true
var draws_agro_on_attack := true

var bracelet_count := 3
var bracelet_cost := 3
