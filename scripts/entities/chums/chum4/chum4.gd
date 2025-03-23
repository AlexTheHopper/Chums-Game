extends Chum
class_name Chum4
var chum_str := "chum4"
var chum_name := "Jabby"

var desc := "No one is really sure where this chum comes from. It seems a little out of place a lot of the time and its very unclear which direction its looking, without eyes and all. With its tail it goes jabby-jab in quick succession."

@onready var default_attack: Dictionary = {"speed": 2.5, #fastest quality still needs to be more than the attack animation length.
										"damage": 10,
										"distance": 1.3,
										"single_target": true}

var default_move_speed := 1.0

var max_health := 100
var start_health := 100

var maintains_agro := false
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 3
var bracelet_cost := 3
