extends Node3D
class_name Quality_Popup

@onready var camera := get_viewport().get_camera_3d()
@onready var chum := get_parent()
var base_scale = Vector3.ONE
var fading_out := false

@export var disp_name: Label
@export var disp_cost: Label
@export var disp_move_speed_title: Label
@export var disp_move_speed_value: Label
@export var disp_damage_title: Label
@export var disp_damage_value: Label
@export var disp_attack_speed_title: Label
@export var disp_attack_speed_value: Label

func _ready() -> void:
	#Set all values:
	disp_name.text = ChumsManager.chum_id_to_name[chum.chum_name]
	disp_cost.text = "Bracelets Needed: %s" %chum.bracelet_cost
	disp_move_speed_value.text = str(chum.quality["move_speed"])
	disp_damage_value.text = str(chum.quality["damage"])
	disp_attack_speed_value.text = str(chum.quality["speed"])
	
	scale = Vector3(0.1, 0.1, 0.1)

func _process(delta: float) -> void:
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

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		queue_free()
