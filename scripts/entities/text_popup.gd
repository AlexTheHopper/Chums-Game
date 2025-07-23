extends Node3D
class_name Text_Popup

@onready var camera := get_viewport().get_camera_3d()
@onready var parent := get_parent()
@onready var mesh_scene : Node
@onready var mesh_node := $Container/MeshNode
var base_scale := Vector3.ONE
var fading_out := false

@export var title_front: Label
@export var text_front: Label

@export var title_back: Label
@export var text_back: Label

var rotations := 1.0

func _ready() -> void:
	#Set visuals:
	var mesh_num = 1
	if Global.current_world_num == 0:
		mesh_num = Global.room_location[0]
	elif Global.current_world_num:
		mesh_num = Global.current_world_num
		
	mesh_scene = load("res://assets/world/quality_popup_%s.tscn" % [mesh_num]).instantiate()
	mesh_node.add_child(mesh_scene)
	
	var text_num = Global.world_map[Global.room_location]["item_count"]
	if text_num not in Global.viewed_lore:
		Global.viewed_lore.append(text_num)
	
	#Set all values:
	#Front
	title_front.text = str(text_num)
	text_front.text = DecorationManager.lore_texts[text_num]["front"]
	#Back
	title_back.text = str(text_num)
	text_back.text = DecorationManager.lore_texts[text_num]["back"]

	scale = Vector3(0.1, 0.1, 0.1)

func _process(_delta: float) -> void:
	
	#Keep facing the camera, rotates on input "rotate"
	if Input.is_action_just_pressed("rotate"):
		rotations += 1.0
	$Container.rotation.y = lerp($Container.rotation.y, rotations * PI - PI, 0.075)
	look_at(camera.global_position)


	if camera and not fading_out:
		var distance = global_position.distance_to(camera.global_position)
		var scale_factor = distance / 12
		scale = lerp(scale, base_scale * scale_factor, 0.05)

	else:
		scale = lerp(scale, Vector3(0.05, 0.05, 0.05), 0.1)
		
		if scale.x < 0.1:
			queue_free()

func remove():
	fading_out = true
