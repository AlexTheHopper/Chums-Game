extends Chum
class_name Chum6
var chum_str := "chum6"
var chum_name := "Healio"


var desc := "Such a thoughtful and kind chum. Whenever an enemy chum is defeated, this little flower will send a helping hand by healing friends who need it."

@onready var default_attack: Dictionary = {"speed": 1.6, #fastest quality still needs to be more than the attack animation length.
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

#This chum cannot walk or attack
func _ready() -> void:
	super()
	self.quality["speed"] = 0.0
	self.quality["move_speed"] = 0.0
