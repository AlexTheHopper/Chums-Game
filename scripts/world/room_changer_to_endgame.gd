extends Area3D
class_name room_changer_to_endgame

@export var active := false
var prisoner_id : int

@onready var player = get_tree().get_first_node_in_group("Player")

func _on_body_entered(body: Node3D) -> void:
	if active and body is Player:
		active = false
		Global.transition_to_endgame(prisoner_id)
