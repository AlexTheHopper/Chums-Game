extends Node

var world1_chums : Dictionary
var close_chums := []
var quality_popup_active = false

func _ready() -> void:
	#Fill world1 chums:
	if Global.dev_mode == false:
		world1_chums[1] = {"object": preload("res://scenes/entities/chums/chum1.tscn"),
							"value": 0.5}
		world1_chums[2] = {"object": preload("res://scenes/entities/chums/chum2.tscn"),
							"value": 0.1}
		world1_chums[3] = {"object": preload("res://scenes/entities/chums/chum3.tscn"),
							"value": 0.5}
		world1_chums[4] = {"object": preload("res://scenes/entities/chums/chum4.tscn"),
							"value": 2.0}
		world1_chums[5] = {"object": preload("res://scenes/entities/chums/chum5.tscn"),
							"value": 1.5}
		world1_chums[6] = {"object": preload("res://scenes/entities/chums/chum6.tscn"),
							"value": 1.5}
		world1_chums[7] = {"object": preload("res://scenes/entities/chums/chum7.tscn"),
							"value": 0.5}
		world1_chums[8] = {"object": preload("res://scenes/entities/chums/chum8.tscn"),
							"value": 2.0}

	else:
		world1_chums[1] = {"object": preload("res://scenes/entities/chums/chum1.tscn"),
							"value": 0.1}
		world1_chums[2] = {"object": preload("res://scenes/entities/chums/chum2.tscn"),
							"value": 0.1}
		world1_chums[3] = {"object": preload("res://scenes/entities/chums/chum3.tscn"),
							"value": 0.1}
		world1_chums[4] = {"object": preload("res://scenes/entities/chums/chum4.tscn"),
							"value": 0.1}
		world1_chums[5] = {"object": preload("res://scenes/entities/chums/chum5.tscn"),
							"value": 0.1}
		world1_chums[6] = {"object": preload("res://scenes/entities/chums/chum6.tscn"),
							"value": 0.1}
		world1_chums[7] = {"object": preload("res://scenes/entities/chums/chum7.tscn"),
							"value": 0.1}
		world1_chums[8] = {"object": preload("res://scenes/entities/chums/chum8.tscn"),
							"value": 0.1}

func get_random_world1_chum(room_value: float):
	#A rooms value is its distance from the lobby. Room (0, 1) has a value of 1.
	#A room will randomly fill with chums but uses its value as currency.
	#A room with a value of 5 could spawn two chums with value 2 and one with value 1.
	#If a room runs out of value, it will not spawn anymore.
	
	#Sample for potential spawns:
	var potential_values = []
	for chum_id in world1_chums:
		if world1_chums[chum_id]["value"] <= room_value:
			potential_values.append(chum_id)
	
	#If nothing available, return
	if len(potential_values) == 0:
		return {"object": null, "value": 0}
	
	var chosen_id = potential_values.pick_random()
	
	return world1_chums[chosen_id]
	
func get_specific_chum(chum_str):
	return load("res://scenes/entities/chums/%s.tscn" % [chum_str])
