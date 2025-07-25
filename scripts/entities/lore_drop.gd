extends Node3D

@onready var text_popup_scene := load("res://scenes/entities/text_popup.tscn")
@onready var popup: Node3D = $Popup
@onready var mesh_scene : Node
@onready var mesh_node: Node3D = $MeshNode

func _ready() -> void:
	#Set visuals:
	var mesh_num = 1
	if Global.current_world_num == 0:
		mesh_num = Global.room_location[1]
	elif Global.current_world_num:
		mesh_num = Global.current_world_num
	
	mesh_scene = load("res://assets/world/lore_drop_%s.tscn" % [mesh_num]).instantiate()
	mesh_node.add_child(mesh_scene)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		popup.add_child(text_popup_scene.instantiate())


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		for text_popup in popup.get_children():
			text_popup.remove()
