extends Node3D

@onready var ps_1: Node3D = $PrisonerStatue1
@onready var ps_2: Node3D = $PrisonerStatue2
@onready var ps_3: Node3D = $PrisonerStatue3
@onready var ps_4: Node3D = $PrisonerStatue4
@onready var room_changer_zone: room_changer_to_endgame = $RoomChanger
var chums: Array

var active := true

func _ready() -> void:
	ps_1.prisoners_changed.connect(_on_prisoners_changed)
	ps_2.prisoners_changed.connect(_on_prisoners_changed)
	ps_3.prisoners_changed.connect(_on_prisoners_changed)
	ps_4.prisoners_changed.connect(_on_prisoners_changed)

func _on_prisoners_changed() -> void:
	chums = [ps_1.current_chum, ps_2.current_chum, ps_3.current_chum, ps_4.current_chum]
	chums.sort()
	
	if chums == [17, 18, 19, 20] and active:
		active = false
		end_sequence()

func end_sequence() -> void:
	print("You Win! :)")
	room_changer_zone.active = true
	room_changer_zone.prisoner_id = chums.pick_random()
