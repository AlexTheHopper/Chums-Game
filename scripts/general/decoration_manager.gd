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
					
					"bones1": preload("res://scenes/world/decorations/bones_1.tscn"),
					"bones2": preload("res://scenes/world/decorations/bones_2.tscn"),
					"bones3": preload("res://scenes/world/decorations/bones_3.tscn"),
					"bones4": preload("res://scenes/world/decorations/bones_4.tscn"),
					"bones5": preload("res://scenes/world/decorations/bones_5.tscn"),
					
					"bonesmoss1": preload("res://scenes/world/decorations/bonesmoss_1.tscn"),
					"bonesmoss2": preload("res://scenes/world/decorations/bonesmoss_2.tscn"),
					"bonesmoss3": preload("res://scenes/world/decorations/bonesmoss_3.tscn"),
					"bonesmoss4": preload("res://scenes/world/decorations/bonesmoss_4.tscn"),
					"bonesmoss5": preload("res://scenes/world/decorations/bonesmoss_5.tscn"),
	
					"tree1": preload("res://scenes/world/decorations/tree_1.tscn"),
					"tree2": preload("res://scenes/world/decorations/tree_2.tscn"),
					
					"rubble1": preload("res://scenes/world/decorations/rubble1.tscn"),
					
					"column1": preload("res://scenes/world/decorations/column1.tscn"),
					"column2": preload("res://scenes/world/decorations/column2.tscn"),
					"column3": preload("res://scenes/world/decorations/column3.tscn"),
					
					"frame1": preload("res://scenes/world/decorations/frame_destructible_1.tscn"),
					"frame2": preload("res://scenes/world/decorations/frame_destructible_2.tscn"),
					
					"fireplace": preload("res://scenes/world/decorations/fireplace.tscn"),
					
					"shrub1": preload("res://scenes/world/decorations/shrub_1.tscn"),
					"shrub2": preload("res://scenes/world/decorations/shrub_2.tscn"),
					"shrub3": preload("res://scenes/world/decorations/shrub_3.tscn"),
					"shrub4": preload("res://scenes/world/decorations/shrub_4.tscn"),
					"shrub5": preload("res://scenes/world/decorations/shrub_5.tscn"),
					"shrub6": preload("res://scenes/world/decorations/shrub_6.tscn"),
					}
	
	decorations_world = {
		1: {"multiplier": 1.0,
			"rarities": {"common": 0.95, "uncommon": 0.98, "rare": 1.0},
			"common": ["grass1", "grass2", "grass3", "grass4", "grass5"],
			"uncommon": ["tree2"],
			"rare": ["bonesmoss1", "bonesmoss2", "bonesmoss3", "bonesmoss4", "bonesmoss5"],
			},

		2: {"multiplier": 0.1,
			"rarities": {"common": 0.95, "uncommon": 0.98, "rare": 1.0},
			"common": ["rubble1", "rubble1", "rubble1", "bones1", "bones2", "bones3", "column2", "column3"],
			"uncommon": ["column1", "frame1", "frame2"],
			"rare": ["column1", "frame1", "frame2"],
			},

		3: {"multiplier": 0.75,
			"rarities": {"common": 0.85, "uncommon": 0.95, "rare": 1.0},
			"common": ["rubble1", "shrub2", "shrub3", "shrub4",  "shrub5",  "shrub6"],
			"uncommon": ["bones1", "bones2", "bones3", "bones4", "bones5", "fireplace", "fireplace", "fireplace", "shrub1"],
			"rare": ["column1"],
			},
		
		4: {"multiplier": 0.5,
			"rarities": {"common": 0.95, "uncommon": 0.98, "rare": 1.0},
			"common": ["rubble1"],
			"uncommon": ["bones1", "bones2", "bones3", "bones4", "bones5"],
			"rare": ["column1"],
			},
	}
	
	lore_texts = {
		0: {"info": "1000 . 0",
			"front": "How many have there been now? Hundreds? Thousands? I can't quite remember...",
			"back": "Yet I have found solace in this futility. A kind of meditation. This will be my life now."},


		1: {"info": "25 . 0",
			"front": "This surely cannot be possible. Twenty five times and twenty five catastrophes...",
			"back": "I do not know how many they are willing to try, I have little hope."},

		2: {"info": "50 . 0",
			"front": "I have seen the one that runs, it shows interesting properties...",
			"back": "With a keen sense of direction, it may not be able to help itself but perhaps others?"},

		3: {"info": "75 . 0",
			"front": "We have been instructed to vary the tests. Perhaps a change in scenery will offer a solution...",
			"back": "Yet I see no significant changes, in the end, all is to perish."},

		4: {"info": "100 . 0",
			"front": "Perhaps we are to be the ones moving on, with an impossibility of unwilling death we cannot cause a catastrophe...",
			"back": "However where is the value in a life that never ends?"},

		5: {"info": "125 . 0",
			"front": "They sometimes show promise these days, but it has become more of an entertainment, betting on the limited time until catastrophe...",
			"back": "Yet, the inevitability reigns and our one shortcoming is revealed."},

		6: {"info": "750 . 0",
			"front": "Some of us have been imprisoned, for we do not posess the skill...",
			"back": "Or at this point, it seems, the luck."},

		7: {"info": "1500 . 0",
			"front": "This one may show the greatest potential of all...",
			"back": "We remain cautiously optimistic."},

		8: {"info": "1501 . 0",
			"front": "Yet again, we are shown what was inevitable from the beginning...",
			"back": "We are close to giving up."},

		9: {"info": "2500 . 0",
			"front": "We are all that remains now. It has gone and left us in this infinite cycle of injustice...",
			"back": "What are we working towards now?"},

		10: {"info": "2525 . 0",
			"front": "Without direction, we change tactics. To create something to finish this for us...",
			"back": "Is it possible?"},

		11: {"info": "2550 . 0",
			"front": "They must be sentient, with intelligence beyond the rest...",
			"back": "To complete the goal, and let us rest."},
	}

func get_random_decoration(world_ns: Array):
	var world_n: int = world_ns.pick_random()
	var chance = randf()
	if chance < decorations_world[world_n]["rarities"]["common"]:
		var rand_name = decorations_world[world_n]["common"].pick_random()
		return [decorations[rand_name], rand_name]
	elif chance < decorations_world[world_n]["rarities"]["uncommon"]:
		var rand_name = decorations_world[world_n]["uncommon"].pick_random()
		return [decorations[rand_name], rand_name]
	else:
		var rand_name = decorations_world[world_n]["rare"].pick_random()
		return [decorations[rand_name], rand_name]
		
func get_common_decoration(world_n):
	var rand_name = decorations_world[world_n]["common"].pick_random()
	return [decorations[rand_name], rand_name]
