extends Node3D

@export var statues: Array[Node3D]
@onready var room_changer_zone: room_changer_to_endgame = $RoomChanger
var chums: Array

var active := true

func _ready() -> void:
	if Global.world_map[Global.room_location]["activated"]:
		active = false
		room_changer_zone.active = true
		room_changer_zone.prisoner_id = [17, 18, 19, 20].pick_random()
		for statue in statues:
			statue.queue_free()
	
	for statue in statues:
		statue.prisoners_changed.connect(_on_prisoners_changed)

func _on_prisoners_changed() -> void:
	chums = []
	for statue in statues:
		chums.append(statue.current_chum)
	chums.sort()
	
	if chums == [17, 18, 19, 20] and active:
		active = false
		end_sequence()

func end_sequence() -> void:
	Global.world_map[Global.room_location]["activated"] = true
	room_changer_zone.active = true
	room_changer_zone.prisoner_id = chums.pick_random()
	for statue in statues:
		statue.animation_player.play("fade")
