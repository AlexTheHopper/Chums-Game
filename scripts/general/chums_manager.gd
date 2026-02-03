extends Node

var close_chums := []
var quality_popup_active = false

#Fill chums:
var chums_list := {
	1: {"destination_world": 1, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum1.tscn")}, #Flamenco
	2: {"destination_world": 1, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum2.tscn")}, #Stump
	3: {"destination_world": 1, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum3.tscn")}, #Pear
	4: {"destination_world": 2, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum4.tscn")}, #Jabby
	5: {"destination_world": 1, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum5.tscn")}, #Slate
	6: {"destination_world": 1, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum6.tscn")}, #Healio
	7: {"destination_world": 1, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum7.tscn")}, #Ring of Pearls
	8: {"destination_world": 1, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum8.tscn")}, #Bolt
	9: {"destination_world": 2, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum9.tscn")}, #Fan
	10: {"destination_world": 4, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum10.tscn")}, #Floaty
	11: {"destination_world": 2, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum11.tscn")}, #Melly
	12: {"destination_world": 2, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum12.tscn")}, #Ram
	13: {"destination_world": 3, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum13.tscn")}, #Leapy
	14: {"destination_world": 1, "guard_world_n": 1, "scene": load("res://scenes/entities/chums/chum14.tscn")}, #Clop
	15: {"destination_world": 2, "guard_world_n": 2, "scene": load("res://scenes/entities/chums/chum15.tscn")}, #Medusa
	16: {"destination_world": 3, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum16.tscn")}, #Basalt
	17: {"destination_world": 1, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum17.tscn")}, #Being
	18: {"destination_world": 2, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum18.tscn")}, #Being
	19: {"destination_world": 3, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum19.tscn")}, #Being
	20: {"destination_world": 4, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum20.tscn")}, #Being
	21: {"destination_world": 3, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum21.tscn")}, #Charles
	22: {"destination_world": 3, "guard_world_n": 3, "scene": load("res://scenes/entities/chums/chum22.tscn")}, #Ashi
	23: {"destination_world": 4, "guard_world_n": 4, "scene": load("res://scenes/entities/chums/chum23.tscn")}, #Globe
	24: {"destination_world": 2, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum24.tscn")}, #Bumble
	25: {"destination_world": 2, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum25.tscn")}, #Hive
	26: {"destination_world": 2, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum26.tscn")}, #Granite
	27: {"destination_world": 4, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum27.tscn")}, #Marble
	28: {"destination_world": 4, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum28.tscn")}, #Echo
	29: {"destination_world": 3, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum29.tscn")}, #Ember
	30: {"destination_world": 3, "guard_world_n": false, "scene": load("res://scenes/entities/chums/chum30.tscn")}, #Goblet
}
var bonus_chums_restricted_ids := [14, 15, 22, 23,
								17, 18, 19, 20,
								6, 7, 16, 26, 27]

var chums_values := {
	1: {
		1: 0.5,
		2: 0.0,
		3: 0.5,
		4: 1.0,
		5: 1.0,
		6: 0.75,
		7: 0.5,
		8: 1.0,
	},
	2: {
		4: 0.5,
		8: 1.5,
		9: 2.0,
		10: 1.5,
		11: 1.0,
		12: 1.0,
		13: 1.5,
		24: 0.0,
		25: 2.0,
		26: 1.0,
	},
	3: {
		4: 1.5,
		6: 1.0,
		8: 1.5,
		11: 2.0,
		13: 2.5,
		16: 1.0,
		21: 1.0,
		29: 0.0,
		30: 2.0,
	},
	4: {
		6: 2.5,
		7: 2.5,
		8: 2.0,
		10: 0.5,
		11: 2.5,
		12: 1.0,
		13: 1.0,
		27: 0.0,
		28: 2.0,
	},
}

#The vector2i defines which room, the keys of that dict are chum ids and the values are the count.
#They are spawned randomly somewhere in the room
#i.e. Vector2i(3, 2) is the boss room from world 3 to world 2
var boss_chums := {
	Vector2i(1, 1): {14: 1, 1: 1, 2: 1, 3: 1, 5: 1, 6: 1},
	Vector2i(1, 2): {14: 1, 1: 1, 2: 1, 3: 1, 5: 1, 13: 1},
	Vector2i(1, 3): {14: 1, 1: 1, 2: 1, 3: 1, 5: 1, 21: 1},
	Vector2i(1, 4): {14: 1, 1: 1, 2: 1, 3: 1, 5: 1, 28: 1},

	Vector2i(2, 1): {15: 1, 9: 1, 10: 1, 11: 1, 12: 1, 6: 1},
	Vector2i(2, 2): {15: 1, 9: 1, 10: 1, 11: 1, 12: 1, 13: 1},
	Vector2i(2, 3): {15: 1, 9: 1, 10: 1, 11: 1, 12: 1, 21: 1},
	Vector2i(2, 4): {15: 1, 9: 1, 10: 1, 11: 1, 12: 1, 28: 1},

	Vector2i(3, 1): {22: 1, 16: 1, 21: 1, 6: 1, 30: 1},
	Vector2i(3, 2): {22: 1, 16: 1, 21: 1, 13: 1, 30: 1},
	Vector2i(3, 3): {22: 1, 16: 1, 21: 2, 30: 1},
	Vector2i(3, 4): {22: 1, 16: 1, 21: 1, 28: 1, 30: 1},
	
	Vector2i(4, 1): {23: 1, 27: 1, 28: 1, 6: 1},
	Vector2i(4, 2): {23: 1, 27: 1, 28: 1, 13: 1},
	Vector2i(4, 3): {23: 1, 27: 1, 28: 1, 21: 1},
	Vector2i(4, 4): {23: 1, 27: 1, 28: 2},
}


func get_world_random_chum(room_value: float, world_n: int) -> Dictionary:
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
	
	return {"object": chums_list[chosen_id]["scene"], "value": chums_values[world_n][chosen_id]}

func get_specific_chum_id(chum_id: int) -> PackedScene:
	if chum_id not in chums_list.keys():
		push_error("error with finding chum_id %s" % chum_id)
		return chums_list[1]["scene"]

	return chums_list[chum_id]["scene"]

func add_bonus_chum(save_id: int) -> void:
	var potential_chums := []

	for chum in get_tree().get_nodes_in_group("Chums_Friend"):
		if chum.chum_id not in bonus_chums_restricted_ids:
			potential_chums.append(chum)

	if potential_chums.size() == 0:
		SaverLoader.game_stats["bonus_chums"].erase(save_id)
	else:
		var chosen_chum = potential_chums.pick_random()
		var chosen_chum_stats := {
			"chum_id": chosen_chum.chum_id,
			"bracelet_cost": int(chosen_chum.bracelet_cost / 2),
			"quality": chosen_chum.quality,
		}
		for quality_type in chosen_chum_stats["quality"].keys():
			chosen_chum_stats["quality"][quality_type] = int(chosen_chum_stats["quality"][quality_type] / 2)
		
		SaverLoader.game_stats["bonus_chums"][save_id] = chosen_chum_stats
	
	SaverLoader.save_gamestate()
