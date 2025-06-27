extends Node3D
class_name Quality_Popup

@onready var camera := get_viewport().get_camera_3d()
@onready var chum := get_parent()
@onready var mesh_scene : Node
@onready var mesh_node := $Container/MeshNode
var base_scale := Vector3.ONE
var fading_out := false

@export var disp_name: Label
@export var disp_cost: Label
@export var disp_health_title: Label
@export var disp_health_value: Label
@export var disp_move_speed_title: Label
@export var disp_move_speed_value: Label
@export var disp_damage_title: Label
@export var disp_damage_value: Label
@export var disp_attack_speed_title: Label
@export var disp_attack_speed_value: Label

@export var disp_name_back: Label
@export var desc_back: Label

var rotations := 1.0

func _ready() -> void:
	#Set visuals:
	var mesh_num = 1
	if Global.current_world_num == 0:
		mesh_num = Global.room_location[0]
	elif Global.current_world_num:
		mesh_num = Global.current_world_num
		
	mesh_scene = load("res://assets/entities/quality_popup_%s.tscn" % [mesh_num]).instantiate()
	mesh_node.add_child(mesh_scene)
	
	#Set all values:
	#Front
	disp_name.text = chum.chum_name
	disp_cost.text = "Bracelets Needed: %s" %chum.bracelet_cost
	disp_health_value.text = get_quality_text(chum.quality["health"])
	disp_move_speed_value.text = get_quality_text(chum.quality["move_speed"])
	disp_damage_value.text = get_quality_text(chum.quality["attack_damage"])
	disp_attack_speed_value.text = get_quality_text(chum.quality["attack_speed"])
	#Back
	disp_name_back.text = disp_name.text
	desc_back.text = chum.desc
	
	scale = Vector3(0.1, 0.1, 0.1)
	chum.has_quality_popup = true
	ChumsManager.quality_popup_active = true

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
		
		#If player cycles through quality popups:
		if Input.is_action_just_pressed("cycle") and len(ChumsManager.close_chums) > 1:
			remove()
			#Cycle through close chums:
			var closest_chum = ChumsManager.close_chums[0]
			ChumsManager.close_chums.erase(closest_chum)
			ChumsManager.close_chums.append(closest_chum)
			
			#Reinstantiate quality popup for close chum(s)
			for close_chum in ChumsManager.close_chums:
				close_chum.interaction_area._on_body_entered(get_tree().get_first_node_in_group("Player"))
	
	else:
		scale = lerp(scale, Vector3(0.05, 0.05, 0.05), 0.1)
		
		if scale.x < 0.1:
			queue_free()

func get_quality_text(quality):	
	if quality == 0:
		return('-')
		
	if quality > 0:
		return('+' + str(quality * 10) + '%')
		
	return(str(quality * 10) + '%')

func remove():
	ChumsManager.quality_popup_active = false
	chum.has_quality_popup = false
	fading_out = true
