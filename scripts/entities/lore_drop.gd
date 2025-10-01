extends Node3D

@onready var text_popup_scene := load("res://scenes/entities/text_popup.tscn")
@onready var popup: Node3D = $Popup
@onready var mesh_scene : Node
@onready var mesh_node: Node3D = $MeshNode

@export var is_custom := false
@export var custom_title_front: String
@export var custom_text_front: String
@export var custom_title_back: String
@export var custom_text_back: String

func _ready() -> void:
	#Set visuals:
	var mesh_num = 1
	if Global.current_world_num == 0:
		mesh_num = Global.room_location[1]
	elif Global.current_world_num:
		mesh_num = Global.current_world_num
	if not mesh_num:
		mesh_num = 1
	
	mesh_scene = load("res://assets/world/lore_drop_%s.tscn" % [mesh_num]).instantiate()
	mesh_node.add_child(mesh_scene)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		var to_add = text_popup_scene.instantiate()
		if is_custom:
			make_custom(to_add)
		popup.add_child(to_add)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		for text_popup in popup.get_children():
			text_popup.remove()

func make_custom(popup_scene) -> void:
	popup_scene.is_custom = true
	popup_scene.custom_title_front = custom_title_front
	popup_scene.custom_text_front = custom_text_front
	popup_scene.custom_title_back = custom_title_back
	popup_scene.custom_text_back = custom_text_back
