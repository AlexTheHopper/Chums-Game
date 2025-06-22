extends Chum
class_name Chum8
var chum_str := "chum8"
var chum_name := "Bolt"

var desc := "palceholder, but also this lil guy will distract enemies attention 80% of the time! :D"

@onready var default_attack: Dictionary = {"speed": 2.5, #fastest quality still needs to be more than the attack animation length.
										"damage": 0.0,
										"distance": 1.3,
										"single_target": true}

var default_move_speed := 7.5
var can_walk := true

var max_health := 50
var start_health := 50

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.8
var changes_agro_on_damaged := true
var draws_agro_on_attack := false
var always_targets_player := false

var bracelet_count := 1 if not Global.dev_mode else 1
var bracelet_cost := 3 if not Global.dev_mode else 1

var target_room_types := ["lobby", "room", "fountain", "void", "statue"]
var can_seek := true

#This chum cannot attack or have strength
func _ready() -> void:
	super()
	self.quality["speed"] = 0.0
	self.quality["damage"] = 0.0
