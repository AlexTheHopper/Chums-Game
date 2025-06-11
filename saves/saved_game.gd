class_name SavedGame
extends Resource

#Player Stats
@export var player_health:float
@export var player_max_health:float
@export var player_bracelets:int
@export var player_max_chums:int

#Friend Chums
@export var friendly_chums:Array[Dictionary]

#World Info
@export var current_world_num:int
@export var world_grid:Array
@export var room_location:Vector2i
@export var room_history:Array
@export var world_map_guide:Dictionary
@export var world_map:Dictionary
