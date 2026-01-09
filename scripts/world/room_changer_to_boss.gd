extends Area3D
class_name room_changer_to_boss

@export var active := false
@export var destination_world_n : int
@onready var source_world_n : int
var override_world := false
var chum_id : int
var to_being_n: int = false


@onready var player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	source_world_n = Global.current_world_num
	
	if not override_world:
		set_chum_id(Global.world_map[Global.room_location]["room_specific_id"])

func set_chum_id(new_chum_id) -> void:
	chum_id = new_chum_id
	destination_world_n = ChumsManager.chums_list[new_chum_id]["destination_world"]
	to_being_n = ChumsManager.chums_list[new_chum_id]["guard_world_n"]

func _on_body_entered(body: Node3D) -> void:
	if active and body is Player:
		active = false
		if to_being_n:
			Global.transition_to_being(source_world_n, to_being_n)
		else:
			Global.transition_to_boss(source_world_n, destination_world_n)
		

func _on_grace_timeout() -> void:
	active = true
