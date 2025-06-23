extends Chum
class_name Chum9
var chum_str := "chum9"
var chum_name := "Fan"


var desc := "TODO"

@onready var default_attack: Dictionary = {"speed": 1.0, #fastest quality still needs to be more than the attack animation length.
										"damage": 5,
										"distance": 1.3,
										"single_target": true}

var default_move_speed := 0.0
var can_walk := false

var max_health := 150
var start_health := 150

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1 if not Global.dev_mode else 1
var bracelet_cost := 3 if not Global.dev_mode else 1

#This chum cannot walk
func _ready() -> void:
	super()
	self.quality["move_speed"] = 0.0
