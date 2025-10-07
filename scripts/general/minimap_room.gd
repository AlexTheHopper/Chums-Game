extends Node2D

@export var main_img: Sprite2D
@export var x_pos_img: Sprite2D
@export var x_neg_img: Sprite2D
@export var z_pos_img: Sprite2D
@export var z_neg_img: Sprite2D

var loc: Vector2i
var x_pos: bool
var x_neg: bool
var z_pos: bool
var z_neg: bool

func _ready() -> void:
	#Set visuals:
	var world_num = 1
	if Global.current_world_num == 0:
		world_num = Global.room_location[0]
	elif Global.current_world_num:
		world_num = Global.current_world_num
	if not world_num:
		world_num = 1

	x_pos = Global.world_map[loc]["has_x_pos"]
	x_pos_img.texture = load("res://assets/minimap/minimap_door_%s.png" % world_num)
	x_neg = Global.world_map[loc]["has_x_neg"]
	x_neg_img.texture = load("res://assets/minimap/minimap_door_%s.png" % world_num)
	z_pos = Global.world_map[loc]["has_z_pos"]
	z_pos_img.texture = load("res://assets/minimap/minimap_door_%s.png" % world_num)
	z_neg = Global.world_map[loc]["has_z_neg"]
	z_neg_img.texture = load("res://assets/minimap/minimap_door_%s.png" % world_num)
	main_img.texture = load("res://assets/minimap/minimap_room_%s.png" % world_num)

	if not x_pos:
		x_pos_img.queue_free()
	elif Global.world_map[loc + Vector2i(1, 0)]["entered"] == true:
		x_pos_img.modulate = Color.DIM_GRAY
	if not x_neg:
		x_neg_img.queue_free()
	elif Global.world_map[loc + Vector2i(-1, 0)]["entered"] == true:
		x_neg_img.modulate = Color.DIM_GRAY
	if not z_pos:
		z_pos_img.queue_free()
	elif Global.world_map[loc + Vector2i(0, 1)]["entered"] == true:
		z_pos_img.modulate = Color.DIM_GRAY
	if not z_neg:
		z_neg_img.queue_free()
	elif Global.world_map[loc + Vector2i(0, -1)]["entered"] == true:
		z_neg_img.modulate = Color.DIM_GRAY

	if loc == Global.room_location:
		main_img.modulate = Color.WEB_GRAY
