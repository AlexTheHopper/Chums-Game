extends Chum
class_name Chum1
var chum_str := "chum1"
var chum_name := "Flamenco"


var desc := "This one-legged pink chum spends its whole day jumping around on its singular foot. With no opposable thumbs nor opposable wings, the only means of travel is hopping, and the only means of attacking prey is pecking. God has forsaken this chum as rather useless, as such it shall spend its days hopping around in search of more things to throw its head into."

@onready var default_attack: Dictionary = {"speed": 1.6, #fastest quality still needs to be more than the attack animation length.
										"damage": 10,
										"distance": 1.3,
										"single_target": true}

var default_move_speed := 1.5
var can_walk := true

var max_health := 100
var start_health := 100

var maintains_agro := false
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false


var bracelet_count := 1 if not Global.dev_mode else 1
var bracelet_cost := 3 if not Global.dev_mode else 1
