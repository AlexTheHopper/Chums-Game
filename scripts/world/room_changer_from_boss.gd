extends Area3D
class_name room_changer_from_boss

@export var active := false
@export var destination_world_n : int

@onready var player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	if Global.current_world_num == 0:
		destination_world_n = Global.room_location[1]

func _on_body_entered(body: Node3D) -> void:
	if active and body is Player:
		active = false
		Global.transition_to_world(destination_world_n)

func _on_grace_timeout() -> void:
	active = true
