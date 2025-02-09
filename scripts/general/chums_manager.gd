extends Node

var world1_chums : Dictionary

func _ready() -> void:
	#Fill world1 chums:
	world1_chums[0] = load("res://scenes/entities/chums/chum1.tscn")
	

func get_random_world1_chum(location: Vector2):
	return world1_chums[0]
	
func get_specific_chum(chum_name):
	return load("res://scenes/entities/chums/%s.tscn" % [chum_name])
