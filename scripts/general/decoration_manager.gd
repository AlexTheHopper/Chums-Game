extends Node

var decorations_world : Dictionary[int, Dictionary]
var lore_text_count: int = 16
var lore_texts : Dictionary[int, Dictionary] = {}

#Radius here is how far it can be from a wall or edge
var decorations_info: Dictionary[String, Dictionary] = {
	"streetlamp": {"scene": preload("res://scenes/world/decorations/streetlamp.tscn"), "radius": 0.5},
	
	"grass_1": {"scene": preload("res://scenes/world/decorations/grass_1.tscn"), "radius": 0.4},
	"grass_2": {"scene": preload("res://scenes/world/decorations/grass_2.tscn"), "radius": 0.4},
	"grass_3": {"scene": preload("res://scenes/world/decorations/grass_3.tscn"), "radius": 0.6},
	"grass_4": {"scene": preload("res://scenes/world/decorations/grass_4.tscn"), "radius": 0.6},
	"grass_5": {"scene": preload("res://scenes/world/decorations/grass_5.tscn"), "radius": 0.8},
	
	"bones_1": {"scene": preload("res://scenes/world/decorations/bones_1.tscn"), "radius": 0.9},
	"bones_2": {"scene": preload("res://scenes/world/decorations/bones_2.tscn"), "radius": 0.8},
	"bones_3": {"scene": preload("res://scenes/world/decorations/bones_3.tscn"), "radius": 0.7},
	"bones_4": {"scene": preload("res://scenes/world/decorations/bones_4.tscn"), "radius": 0.9},
	"bones_5": {"scene": preload("res://scenes/world/decorations/bones_5.tscn"), "radius": 0.9},

	"bonesmoss_1": {"scene": preload("res://scenes/world/decorations/bonesmoss_1.tscn"), "radius": 0.9},
	"bonesmoss_2": {"scene": preload("res://scenes/world/decorations/bonesmoss_2.tscn"), "radius": 0.8},
	"bonesmoss_3": {"scene": preload("res://scenes/world/decorations/bonesmoss_3.tscn"), "radius": 0.8},
	"bonesmoss_4": {"scene": preload("res://scenes/world/decorations/bonesmoss_4.tscn"), "radius": 1.0},
	"bonesmoss_5": {"scene": preload("res://scenes/world/decorations/bonesmoss_5.tscn"), "radius": 0.9},

	"tree_1": {"scene": preload("res://scenes/world/decorations/tree_1.tscn"), "radius": 1.5},
	"tree_2": {"scene": preload("res://scenes/world/decorations/tree_2.tscn"), "radius": 1.5},
	
	"rubble_1": {"scene": preload("res://scenes/world/decorations/rubble_1.tscn"), "radius": 0.9},
	
	"column_1": {"scene": preload("res://scenes/world/decorations/column_1.tscn"), "radius": 0.8},
	"column_2": {"scene": preload("res://scenes/world/decorations/column_2.tscn"), "radius": 0.6},
	"column_3": {"scene": preload("res://scenes/world/decorations/column_3.tscn"), "radius": 0.6},
	"column_4": {"scene": preload("res://scenes/world/decorations/column_4.tscn"), "radius": 0.5},
	"column_5": {"scene": preload("res://scenes/world/decorations/column_5.tscn"), "radius": 0.0},
	
	"frame_destructible_1": {"scene": preload("res://scenes/world/decorations/frame_destructible_1.tscn"), "radius": 0.9},
	"frame_destructible_2": {"scene": preload("res://scenes/world/decorations/frame_destructible_2.tscn"), "radius": 0.9},
	
	"fireplace_1": {"scene": preload("res://scenes/world/decorations/fireplace_1.tscn"), "radius": 1.0},
	
	"shrub_1": {"scene": preload("res://scenes/world/decorations/shrub_1.tscn"), "radius": 0.5},
	"shrub_2": {"scene": preload("res://scenes/world/decorations/shrub_2.tscn"), "radius": 0.4},
	"shrub_3": {"scene": preload("res://scenes/world/decorations/shrub_3.tscn"), "radius": 0.4},
	"shrub_4": {"scene": preload("res://scenes/world/decorations/shrub_4.tscn"), "radius": 0.6},
	"shrub_5": {"scene": preload("res://scenes/world/decorations/shrub_5.tscn"), "radius": 0.6},
	"shrub_6": {"scene": preload("res://scenes/world/decorations/shrub_6.tscn"), "radius": 0.8},
	}

func _ready() -> void:	
	decorations_world = {
		1: {"multiplier": 1.0,
			"rarities": {"common": 0.95, "uncommon": 0.98, "rare": 1.0},
			"common": ["grass_1", "grass_2", "grass_3", "grass_4", "grass_5"],
			"uncommon": ["tree_2"],
			"rare": ["bonesmoss_1", "bonesmoss_2", "bonesmoss_3", "bonesmoss_4", "bonesmoss_5"],
			},

		2: {"multiplier": 0.1,
			"rarities": {"common": 0.95, "uncommon": 0.98, "rare": 1.0},
			"common": ["rubble_1", "rubble_1", "rubble_1", "bones_1", "bones_2", "bones_3", "column_2", "column_3"],
			"uncommon": ["column_1", "frame_destructible_1", "frame_destructible_2"],
			"rare": ["column_1", "frame_destructible_1", "frame_destructible_2"],
			},

		3: {"multiplier": 0.75,
			"rarities": {"common": 0.85, "uncommon": 0.95, "rare": 1.0},
			"common": ["rubble_1", "shrub_2", "shrub_3", "shrub_4",  "shrub_5",  "shrub_6"],
			"uncommon": ["bones_1", "bones_2", "bones_3", "bones_4", "bones_5", "fireplace_1", "fireplace_1", "fireplace_1", "shrub_1"],
			"rare": ["column_1"],
			},
		
		4: {"multiplier": 0.5,
			"rarities": {"common": 0.95, "uncommon": 0.99, "rare": 1.0},
			"common": ["rubble_1", "column_4", "column_5"],
			"uncommon": ["bones_1", "bones_2", "bones_3", "bones_4", "bones_5"],
			"rare": ["frame_destructible_1", "frame_destructible_2"],
			},
	}
	for n in range(lore_text_count):
		lore_texts[n] = {"info": "LORE_%s_INFO" % n,
						"front": "LORE_%s_FRONT" % n,
						"back": "LORE_%s_BACK" % n}
	#lore_texts = {
		#0: {"info": "1000 . 0",
			#"front": "How many have there been now? Hundreds? Thousands? I can't quite remember...",
			#"back": "Yet I have found solace in this futility. A kind of meditation. This will be my life now."},
#
#
		#1: {"info": "25 . 0",
			#"front": "This surely cannot be possible. Twenty five times and twenty five catastrophes...",
			#"back": "I do not know how many they are willing to try, I have little hope."},
#
		#2: {"info": "50 . 0",
			#"front": "I have seen the one that runs, it shows interesting properties...",
			#"back": "With a keen sense of direction, it may not be able to help itself but perhaps others?"},
#
		#3: {"info": "75 . 0",
			#"front": "We have been instructed to vary the tests. Perhaps a change in scenery will offer a solution...",
			#"back": "Yet I see no significant changes, in the end, all is to perish."},
#
		#4: {"info": "100 . 0",
			#"front": "Perhaps we are to be the ones moving on, with the impossibility of unapproved death, there shall be many catastrophes to come...",
			#"back": "However where is the value in a life that never ends?"},
#
		#5: {"info": "125 . 0",
			#"front": "They sometimes show promise these days, but it has become more of an entertainment, betting on the limited time until catastrophe...",
			#"back": "Yet, the inevitability reigns and our one shortcoming is revealed."},
#
		#6: {"info": "750 . 0",
			#"front": "Some of us have been imprisoned, it seems we are to be locked in this cycle without complaining or suggesting improvements...",
			#"back": "We fear the cages."},
#
		#7: {"info": "800 . 0",
			#"front": "The imprisoned ones brought a fresh light, new ideas, possible solutions...",
			#"back": "But we do not know where they are now. Above all else, I hope they return."},
#
		#8: {"info": "1500 . 0",
			#"front": "This one may show the greatest potential of all...",
			#"back": "We remain cautiously optimistic."},
#
		#9: {"info": "1501 . 0",
			#"front": "Yet again, we are shown what was inevitable from the beginning...",
			#"back": "We are close to giving up."},
#
		#10: {"info": "1250 . 0",
			#"front": "They have the pools, the statues, the means of working together, but nothing works...",
			#"back": "The pursuit of our new world's utopia seems more and more futile."},
#
		#11: {"info": "1300 . 0",
			#"front": "Many of the records are lost now. Some due to time, some seemingly on purpose. We are left repeating our own mistakes, blindly reaching for a miracle.",
			#"back": "What have we tried before? What worked? What didn't?"},
#
		#12: {"info": "2500 . 0",
			#"front": "We are all that remains now. It has gone and left us in this infinite cycle of injustice...",
			#"back": "What are we working towards now?"},
#
		#13: {"info": "2501 . 0",
			#"front": "Now on our own, we create the uncaging statues, in hope of their return...",
			#"back": "They may truly be the only ones to end the cycle now."},
#
		#14: {"info": "2525 . 0",
			#"front": "Without direction, we change tactics. To create something to finish this for us...",
			#"back": "Is it possible?"},
#
		#15: {"info": "2550 . 0",
			#"front": "They must be sentient, with intelligence beyond the rest...",
			#"back": "To complete the goal, and let us rest."},
	#}

func get_random_decoration(world_ns: Array):
	var world_n: int = world_ns.pick_random()
	var chance = randf()
	if chance < decorations_world[world_n]["rarities"]["common"]:
		var rand_name = decorations_world[world_n]["common"].pick_random()
		return decorations_info[rand_name]
	elif chance < decorations_world[world_n]["rarities"]["uncommon"]:
		var rand_name = decorations_world[world_n]["uncommon"].pick_random()
		return decorations_info[rand_name]
	else:
		var rand_name = decorations_world[world_n]["rare"].pick_random()
		return decorations_info[rand_name]
		
func get_common_decoration(world_n):
	var rand_name = decorations_world[world_n]["common"].pick_random()
	return decorations_info[rand_name]

func get_terrain(world_n: int, id: int) -> PackedScene:
	var terrain := load("res://scenes/world/terrains/terrain_world_%s_%s.tscn" % [world_n, id])
	if not terrain:
		push_error("error with finding terrain world %s id %s" % [world_n, id])
		return load("res://scenes/world/terrains/terrain_world_1_0.tscn")
	return terrain
