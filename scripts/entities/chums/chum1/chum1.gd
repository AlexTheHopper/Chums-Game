extends Chum
class_name Chum_1
@onready var chum_name := "chum1"

@onready var attack_1: Dictionary = {"speed": randf_range(1, 2),
									"damage": randf_range(0.8, 1.2),
									"distance": 1.5}

var move_speed = randf_range(1.8, 2.5)
