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
			"destination_world": 1, "guard_world_n": false}, #Flamenco
		2: {"object": preload("res://scenes/entities/chums/chum2.tscn"),
			"destination_world": 1, "guard_world_n": false}, #Stump
		3: {"object": preload("res://scenes/entities/chums/chum3.tscn"),
			"destination_world": 1, "guard_world_n": false}, #Pear
		4: {"object": preload("res://scenes/entities/chums/chum4.tscn"),
			"destination_world": 2, "guard_world_n": false}, #Jabby
		5: {"object": preload("res://scenes/entities/chums/chum5.tscn"),
			"destination_world": 1, "guard_world_n": false}, #Slate
		6: {"object": preload("res://scenes/entities/chums/chum6.tscn"),
			"destination_world": 1, "guard_world_n": false}, #Healio
		7: {"object": preload("res://scenes/entities/chums/chum7.tscn"),
			"destination_world": 1, "guard_world_n": false}, #Ring of Pearls
		8: {"object": preload("res://scenes/entities/chums/chum8.tscn"),
			"destination_world": 1, "guard_world_n": false}, #Bolt
		9: {"object": preload("res://scenes/entities/chums/chum9.tscn"),
			"destination_world": 2, "guard_world_n": false}, #Fan
		10: {"object": preload("res://scenes/entities/chums/chum10.tscn"),
			"destination_world": 4, "guard_world_n": false}, #Floaty
		11: {"object": preload("res://scenes/entities/chums/chum11.tscn"),
			"destination_world": 2, "guard_world_n": false}, #Melly
		12: {"object": preload("res://scenes/entities/chums/chum12.tscn"),
			"destination_world": 2, "guard_world_n": false}, #Ram
		13: {"object": preload("res://scenes/entities/chums/chum13.tscn"),
			"destination_world": 3, "guard_world_n": false}, #Leapy
		14: {"object": preload("res://scenes/entities/chums/chum14.tscn"),
			"destination_world": 1, "guard_world_n": 1}, #Clop
		15: {"object": preload("res://scenes/entities/chums/chum15.tscn"),
			"destination_world": 2, "guard_world_n": 2}, #Medusa
		16: {"object": preload("res://scenes/entities/chums/chum16.tscn"),
			"destination_world": 3, "guard_world_n": false}, #Basalt
		17: {"object": preload("res://scenes/entities/chums/chum17.tscn"),
			"destination_world": 1, "guard_world_n": false}, #Being
		18: {"object": preload("res://scenes/entities/chums/chum18.tscn"),
			"destination_world": 2, "guard_world_n": false}, #Being
		19: {"object": preload("res://scenes/entities/chums/chum19.tscn"),
			"destination_world": 3, "guard_world_n": false}, #Being
		20: {"object": preload("res://scenes/entities/chums/chum20.tscn"),
			"destination_world": 4, "guard_world_n": false}, #Being
		21: {"object": preload("res://scenes/entities/chums/chum21.tscn"),
			"destination_world": 3, "guard_world_n": false}, #Charles
		22: {"object": preload("res://scenes/entities/chums/chum22.tscn"),
			"destination_world": 3, "guard_world_n": 3}, #Ashi
		23: {"object": preload("res://scenes/entities/chums/chum23.tscn"),
			"destination_world": 4, "guard_world_n": 4}, #Globe
		24: {"object": preload("res://scenes/entities/chums/chum24.tscn"),
			"destination_world": 2, "guard_world_n": false}, #Bumble
		25: {"object": preload("res://scenes/entities/chums/chum25.tscn"),
			"destination_world": 2, "guard_world_n": false}, #Hive
		26: {"object": preload("res://scenes/entities/chums/chum26.tscn"),
			"destination_world": 2, "guard_world_n": false}, #Granite
		27: {"object": preload("res://scenes/entities/chums/chum27.tscn"),
			"destination_world": 4, "guard_world_n": false}, #Marble
		28: {"object": preload("res://scenes/entities/chums/chum28.tscn"),
			"destination_world": 4, "guard_world_n": false}, #TODO
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
			8: 1.5,
			9: 2.0,
			10: 1.5,
			11: 1.0,
			12: 1.0,
			13: 1.5,
			24: 0.5,
			25: 2.0,
			26: 1.0,
		},
		3: {
			4: 3.5,
			6: 1.0,
			8: 2.0,
			11: 2.5,
			13: 5.0,
			16: 1.0,
			21: 1.0
		},
		4: {
			6: 2.5,
			7: 2.5,
			8: 2.0,
			10: 0.1,
			11: 2.5,
			12: 1.0,
			13: 1.0,
			27: 1.0,
		},
	}
	
	#The vector2i defines which room, the keys of that dict are chum ids and the values are the count.
	#They are spawned randomly somewhere in the room
	#i.e. Vector2i(3, 2) is the boss room from world 3 to world 2
	boss_chums = {
		Vector2i(1, 1): {14: 1, 3: 4, 4: 4},
		Vector2i(1, 2): {14: 1, 3: 4, 4: 4},
		Vector2i(1, 3): {14: 1, 3: 4, 4: 4},
		Vector2i(1, 4): {14: 1, 3: 4, 4: 4},

		Vector2i(2, 1): {15: 1, 10: 3, 5: 3},
		Vector2i(2, 2): {15: 1, 10: 2, 4: 2, 12: 2},
		Vector2i(2, 3): {15: 1, 10: 2, 4: 2, 12: 2, 13: 2},
		Vector2i(2, 4): {15: 1, 10: 2, 4: 2, 12: 2, 13: 2},

		Vector2i(3, 1): {3: 5, 5: 3, 22: 1},
		Vector2i(3, 2): {3: 5, 4: 3, 22: 1},
		Vector2i(3, 3): {3: 5, 4: 3, 22: 1},
		Vector2i(3, 4): {3: 5, 4: 3, 22: 1},
		
		Vector2i(4, 1): {3: 5, 5: 3, 23: 1},
		Vector2i(4, 2): {3: 5, 4: 3, 23: 1},
		Vector2i(4, 3): {3: 5, 4: 3, 23: 1},
		Vector2i(4, 4): {3: 5, 4: 3, 23: 1},
	}

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
	if chum_id not in chums_list.keys():
		push_error("error with finding chum_id %s" % chum_id)
		return chums_list[1]["object"]

	return chums_list[chum_id]["object"]
