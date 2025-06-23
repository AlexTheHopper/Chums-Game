extends Chum
class_name Chum7
var chum_str := "chum7"
var chum_name := "Ring of Pearls"


var desc := "Down on your luck with a low amount of friendship bracelets? Fear not, behold this flower which grants you an extra bracelet on every enemy defeat!"

var min_attack_speed := 2.55
@onready var default_attack: Dictionary = {"speed": 0.0, #fastest quality still needs to be more than the attack animation length.
										"damage": 10,
										"distance": 1.3,
										"single_target": true}

var default_move_speed := 0.0
var can_walk := false

var max_health := 50
var start_health := 50

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1 if not Global.dev_mode else 1
var bracelet_cost := 3 if not Global.dev_mode else 1

#This chum cannot walk or attack or have strength
func _ready() -> void:
	super()
	self.quality["speed"] = 0.0
	self.quality["move_speed"] = 0.0
	self.quality["damage"] = 0.0
