extends Node

var decorations : Dictionary[String, PackedScene]
var decorations_world : Dictionary[int, Dictionary]

var lore_texts : Dictionary[int, Dictionary]

func _ready() -> void:
	decorations = {"streetlamp": preload("res://scenes/world/streetlamp.tscn"),
	
					"grass1": preload("res://scenes/world/decorations/grass_1.tscn"),
					"grass2": preload("res://scenes/world/decorations/grass_2.tscn"),
					"grass3": preload("res://scenes/world/decorations/grass_3.tscn"),
					"grass4": preload("res://scenes/world/decorations/grass_4.tscn"),
					"grass5": preload("res://scenes/world/decorations/grass_5.tscn"),
	
					"tree1": preload("res://scenes/world/decorations/tree_1.tscn"),
					"tree2": preload("res://scenes/world/decorations/tree_2.tscn"),
					
					"rubble1": preload("res://scenes/world/decorations/rubble1.tscn"),
					
					"column1": preload("res://scenes/world/decorations/column1.tscn"),}
	
	decorations_world = {
		1: {"multiplier": 1.0,
			"common": ["grass1", "grass2", "grass3", "grass4", "grass5"],
			"uncommon": ["tree2"],
			"rare": ["tree1"]
			},

		2: {"multiplier": 0.1,
			"common": ["rubble1"],
			"uncommon": ["column1"],
			"rare": ["column1"]
			},

		3: {"multiplier": 0.5,
			"common": ["rubble1"],
			"uncommon": ["column1"],
			"rare": ["column1"]
			},
	}
	
	lore_texts = {
		0: {"front": "How many...",
			"back": "...is too many?"},

		1: {"front": "They fight well...",
			"back": "...but not wisely."},

		2: {"front": "This time...",
			"back": "...that one is different."},

		3: {"front": "Perhaps the search is over...",
			"back": "...or perhaps, this one can take over."},

		4: {"front": "I am not even sure...",
			"back": "...if I know how to count this high."},
	}

func get_random_decoration(world_n):
	var chance = randf()
	if chance < 0.95:
		var rand_name = decorations_world[world_n]["common"].pick_random()
		return [decorations[rand_name], rand_name]
	elif chance < 0.98:
		var rand_name = decorations_world[world_n]["uncommon"].pick_random()
		return [decorations[rand_name], rand_name]
	else:
		var rand_name = decorations_world[world_n]["rare"].pick_random()
		return [decorations[rand_name], rand_name]
		
func get_common_decoration(world_n):
	var rand_name = decorations_world[world_n]["common"].pick_random()
	return [decorations[rand_name], rand_name]
