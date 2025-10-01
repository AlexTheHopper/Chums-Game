extends Area3D
class_name room_changer_tutorial

@export var x_dir := 0
@export var z_dir := 0
@export var active := false

@onready var player := get_tree().get_first_node_in_group("Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	active = false

func _on_body_entered(body: Node3D) -> void:
	if active and body is Player:
		active = false
		Global.return_to_menu(false)

func _on_grace_timeout() -> void:
	active = true
