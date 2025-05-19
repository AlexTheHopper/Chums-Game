extends Node

var decorations : Dictionary
var decorations_world1_common : Array
var decorations_world1_uncommon : Array
var decorations_world1_rare : Array

func _ready() -> void:
	decorations = {"streetlamp": preload("res://scenes/world/streetlamp.tscn"),
	
					"grass1": preload("res://scenes/world/decorations/grass_1.tscn"),
					"grass2": preload("res://scenes/world/decorations/grass_2.tscn"),
					"grass3": preload("res://scenes/world/decorations/grass_3.tscn"),
					"grass4": preload("res://scenes/world/decorations/grass_4.tscn"),
					"grass5": preload("res://scenes/world/decorations/grass_5.tscn"),
								
					"tree1": preload("res://scenes/world/decorations/tree_1.tscn"),}
					
	decorations_world1_common = ["grass1", "grass2", "grass3", "grass4", "grass5"]
	decorations_world1_uncommon = ["tree1"]
	decorations_world1_rare = ["tree1"]

func get_random_decoration_world1():
	var chance = randf()
	var boost = Functions.map_range(Global.room_location.length(), Vector2(0, Global.map_size), Vector2(0, 0.1))
	if chance + boost < 0.95:
		var rand_name = decorations_world1_common.pick_random()
		return [decorations[rand_name], rand_name]
	elif chance + boost < 0.98:
		var rand_name = decorations_world1_uncommon.pick_random()
		return [decorations[rand_name], rand_name]
	else:
		var rand_name = decorations_world1_rare.pick_random()
		return [decorations[rand_name], rand_name]
		
func get_common_decoration_world1():
	var rand_name = decorations_world1_common.pick_random()
	return [decorations[rand_name], rand_name]
