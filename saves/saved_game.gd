class_name SavedGame
extends Resource

#Save Time
@export var unix_time:int
@export var date_time:String
@export var save_seed:int

#Player Stats
@export var player_health:float
@export var player_max_health:float
@export var player_bracelets:int
@export var player_max_chums:int
@export var player_damage: int
@export var player_extra_damage: int

#Friend Chums
@export var friendly_chums:Array[Dictionary]

#World Info
@export var world_transition_count:int
@export var viewed_lore:Array
@export var current_world_num:int
@export var world_grid:Array
@export var room_location:Vector2i
@export var room_history:Array
@export var world_map:Dictionary
