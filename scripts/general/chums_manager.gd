extends Node

var chums_list : Dictionary
var chums_values : Dictionary
var boss_chums : Dictionary
var close_chums := []
var quality_popup_active = false

func _ready() -> void:
	#Fill chums:
	chums_list = {
		1: {"object": preload("res://scenes/entities/chums/chum1.tscn"),
			"destination_world": 1}, #Flamenco
		2: {"object": preload("res://scenes/entities/chums/chum2.tscn"),
			"destination_world": 1}, #Stump
		3: {"object": preload("res://scenes/entities/chums/chum3.tscn"),
			"destination_world": 1}, #Pear
		4: {"object": preload("res://scenes/entities/chums/chum4.tscn"),
			"destination_world": 2}, #Jabby
		5: {"object": preload("res://scenes/entities/chums/chum5.tscn"),
			"destination_world": 1}, #Slate
		6: {"object": preload("res://scenes/entities/chums/chum6.tscn"),
			"destination_world": 1}, #Healio
		7: {"object": preload("res://scenes/entities/chums/chum7.tscn"),
			"destination_world": 1}, #Ring of Pearls
		8: {"object": preload("res://scenes/entities/chums/chum8.tscn"),
			"destination_world": 1}, #Bolt
		9: {"object": preload("res://scenes/entities/chums/chum9.tscn"),
			"destination_world": 2}, #Fan
	}

	chums_values = {
		1: {
			1: 0.5,
			2: 0.1,
			3: 0.5,
			4: 2.0,
			5: 1.5,
			6: 1.5,
			7: 0.5,
			8: 2.0,
		},
		2: {
			4: 0.5,
			8: 2.0,
			9: 2.0,
		},
	}
	
	#The vector2i defines which room, the keys of that dict are chum ids and the values are the count.
	#They are spawned randomly somewhere in the room
	boss_chums = {
		Vector2i(1, 1): {4: 5,},
		Vector2i(1, 2): {4: 5,},
		Vector2i(2, 1): {4: 5,},
		Vector2i(2, 2): {4: 5,},
	}

	if Global.dev_mode:
		for world_n in chums_values:
			for chum_id in chums_values[world_n]:
				chums_values[world_n][chum_id] = 0.01

func get_world_random_chum(room_value: float, world_n: int):
	#A rooms value is its distance from the lobby. Room (0, 1) has a value of 1.
	#A room will randomly fill with chums but uses its value as currency.
	#A room with a value of 5 could spawn two chums with value 2 and one with value 1.
	#If a room runs out of value, it will not spawn anymore.
	
	#Sample for potential spawns:
	var potential_ids = []
	for chum_id in chums_values[world_n]:
		if chums_values[world_n][chum_id] <= room_value:
			potential_ids.append(chum_id)
	
	#If nothing available, return
	if len(potential_ids) == 0:
		return {"object": null, "value": 0}
	
	var chosen_id = potential_ids.pick_random()
	
	return {"object": chums_list[chosen_id]["object"], "value": chums_values[world_n][chosen_id]}
	
func get_specific_chum_str(chum_str):
	return load("res://scenes/entities/chums/%s.tscn" % [chum_str])

func get_specific_chum_id(chum_id):
	return chums_list[chum_id]["object"]
