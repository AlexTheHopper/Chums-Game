extends Area3D
class_name room_changer_to_boss

@export var active := false
@export var destination_world_n : int
var override_world := false
var chum_id : int
@onready var source_world_n : int

@onready var player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	source_world_n = Global.current_world_num
	
	if not override_world:
		chum_id = Global.world_map[Global.room_location]["statue_id"]
		destination_world_n = ChumsManager.chums_list[chum_id]["destination_world"]

func _on_body_entered(body: Node3D) -> void:
	if active and body is Player:
		active = false
		Global.current_room_node.save_room()
		Global.transition_to_boss(source_world_n, destination_world_n)
		

func _on_grace_timeout() -> void:
	active = true
