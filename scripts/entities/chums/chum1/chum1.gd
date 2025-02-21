extends Chum
class_name Chum_1
@onready var chum_name := "chum1"

@onready var default_attack: Dictionary = {"speed": 1.5,
										"damage": 1,
										"distance": 1.3,
										"single_target": true}

var default_move_speed = 1.5
var max_health := 5.0
var start_health := 1.0

var bracelet_count := 100
var bracelet_cost := 3
