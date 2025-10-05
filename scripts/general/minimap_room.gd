extends Node2D

@export var main_img: Sprite2D
@export var x_pos_img: Sprite2D
@export var x_neg_img: Sprite2D
@export var z_pos_img: Sprite2D
@export var z_neg_img: Sprite2D

var x_pos := true
var x_neg := true
var z_pos := true
var z_neg := true

func _ready() -> void:
	if not x_pos:
		x_pos_img.queue_free()
	if not x_neg:
		x_neg_img.queue_free()
	if not z_pos:
		z_pos_img.queue_free()
	if not z_neg:
		z_neg_img.queue_free()
