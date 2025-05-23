extends Node

var world1_chums : Dictionary
var close_chums := []
var quality_popup_active = false

func _ready() -> void:
	#Fill world1 chums:
	world1_chums[0.0] = preload("res://scenes/entities/chums/chum1.tscn")
	world1_chums[10.1] = preload("res://scenes/entities/chums/chum2.tscn")
	world1_chums[10.2] = preload("res://scenes/entities/chums/chum3.tscn")
	world1_chums[10.3] = preload("res://scenes/entities/chums/chum4.tscn")
	world1_chums[10.4] = preload("res://scenes/entities/chums/chum5.tscn")
	world1_chums[10.01] = preload("res://scenes/entities/chums/chum6.tscn")
	world1_chums[10.02] = preload("res://scenes/entities/chums/chum7.tscn")
	world1_chums[0.03] = preload("res://scenes/entities/chums/chum8.tscn")

func get_random_world1_chum(room_value: float):
	#A rooms value is its distance from the lobby. Room (0, 1) has a value of 1.
	#A room will randomly fill with chums but uses its value as currency.
	#A room with a value of 5 could spawn two chums with value 2 and one with value 1.
	#If a room runs out of value, it will not spawn anymore.
	
	#Sample for potential spawns:
	var potential_values = []
	for chum_value in world1_chums:
		if chum_value <= room_value:
			potential_values.append(chum_value)
	
	#If nothing available, return
	if len(potential_values) == 0:
		return {"object": null, "value": 0}
	
	var chosen_value = potential_values.pick_random()
	
	return {"object": world1_chums[chosen_value], "value": chosen_value}
	
func get_specific_chum(chum_str):
	return load("res://scenes/entities/chums/%s.tscn" % [chum_str])
